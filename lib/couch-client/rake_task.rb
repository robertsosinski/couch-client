require 'rake'
require 'rake/tasklib'
require 'set'
require 'pathname'

module CouchClient
  # RakeTask is a namespace for all Rake tasks that are bundled with
  # CouchClient, such as database creation, sync, compaction and deletion.
  class RakeTask < ::Rake::TaskLib
    class MissingCouchClientConnection < Exception; end
    
    attr_accessor :connection, :design_path
    
    # Start using CouchClient::RakeTask by constructing a new instance with a block.
    #
    #   CouchClient::RakeTask.new do |c|
    #     c.connection = Couch
    #     c.design_path = "./app/designs"
    #   end
    #
    # CouchClient::RakeTask.new takes the following options.
    #
    #  connection: A CouchClient Connection, default being `Couch`.
    #  design_path: The path where design documents are stored, default being "./designs".
    def initialize(&block)
      instance_eval(&block) if block_given?
      
      begin
        @connection ||= Object.const_get("Couch")
      rescue NameError
        raise MissingCouchClientConnection.new("specify a CouchClient connection within your RakeTask setup.")
      end
      
      @design_path = Pathname.new(@design_path || './designs')
      
      # Create Rake tasks.
      namespace :couch do
        desc "Syncs design documents with the database."
        task :sync do
          sync
        end
        
        desc "Creates the database."
        task :create do
          create
        end
        
        desc "Deletes the database and all its data."
        task :delete do
          delete
        end
        
        desc "Compacts the database."
        task :compact do
          compact
        end
      end
    end
    
    def sync
      # Fetch all design documents that are cuurently saved in the database.
      saved_design_docs = @connection.all_design_docs("include_docs" => true)
      local_design_docs = {}
      
      design_path_depth = design_path.to_s.count("/") + 1
      
      # Recurse though the design directory and construct a hash of design functions.
      recurser = lambda do |path|
        path_breadcrumbs = path.to_s.match("[^\.]+")[0].split("/")[design_path_depth..-1] # e.g. ["people", "views", "all", "map"]
        path_hash_follow = path_breadcrumbs.reduce(""){|memo, key| memo + "['#{key}']"}   # e.g. ['people']['views']['all']['map']
        
        if path.directory?
          # Set an empty hash for the directory.
          eval("local_design_docs#{path_hash_follow} = {}")
          
          # Reject hidden filenames (filesnames that begin with a ".").
          path.children.reject{|p| p.basename.to_s.match(/^\./)}.each do |child|
            # Continue recursion.
            recurser.call(child)
          end
        else
          # Set a field with design function data.
          eval("local_design_docs#{path_hash_follow} = #{path.read.inspect}")
        end
      end
      
      recurser.call(design_path)
      
      # Get a set of id's that are currently saved and a set that are avaiable locally.
      saved_ids = saved_design_docs.map{|doc| doc["id"].gsub(/^_design\//, "")}.to_set
      local_ids = local_design_docs.keys.to_set
      
      doc_ids_to_create = local_ids.difference(saved_ids).to_a
      doc_ids_to_update = saved_ids.intersection(local_ids).to_a
      doc_ids_to_delete = saved_ids.difference(local_ids).to_a
      
      # Create any new design documents.
      doc_ids_to_create.each do |id|
        new_doc = @connection.build
        new_doc.id = "_design/#{id}"
        new_doc.merge!(local_design_docs[id])
        new_doc.merge!({"language" => "javascript"})
        
        if new_doc.save
          puts "Creating: #{new_doc.id} -- #{new_doc.rev}"
        else
          puts "Failure:  #{new_doc.id} -- #{new_doc.error.inspect}"
        end
      end
      
      # Construct design documents that already exist.
      doc_ids_to_update.each do |id|
        old_doc = saved_design_docs.detect{|d| d["id"] == "_design/#{id}"}["doc"]
        
        new_doc = @connection.build
        new_doc.id  = old_doc.id
        new_doc.rev = old_doc.rev
        new_doc.merge!(local_design_docs[id])
        new_doc.merge!({"language" => "javascript"})
        
        # If the new document is the same as what is on the server
        if old_doc == new_doc
          # Keep the old design document.
          puts "Keeping:  #{old_doc.id} -- #{old_doc.rev}"
        else
          # Else save the new design docuemnt.
          if new_doc.save
            puts "Updating: #{new_doc.id} -- #{new_doc.rev}"
          else
            puts "Failure:  #{new_doc.id} -- #{new_doc.error.inspect}"
          end
        end
      end
      
      # Delete any documents that are not available locally.
      doc_ids_to_delete.each do |id|
        old_doc = saved_design_docs.detect{|d| d["id"] == "_design/#{id}"}["doc"]
        
        if old_doc.delete!
          puts "Deleting: #{old_doc.id} -- #{old_doc.rev}"
        else
          puts "Failure:  #{old_doc.id} -- #{new_doc.error.inspect}"
        end
      end
    end
    
    def create
      resp = @connection.database.create
      if resp["ok"]
        puts "Created."
      else
        puts "The database could not be created, the file already exists."
      end
    end
    
    def delete
      resp = @connection.database.delete!
      
      if resp["ok"]
        puts "Deleted."
      else
        puts "The database could not be deleted, the file does not exist."
      end
    end
    
    def compact
      resp = @connection.database.compact!
      
      if resp["ok"]
        puts "Compaction Complete."
      else
        utils_uri = lambda{
          handler = handler = @connection.hookup.handler
          handler.uri.gsub(/#{handler.database}$/, "_utils")
        }.call
        
        puts "The database could not be compacted, see #{utils_uri} for more information."
      end
    end
  end
end