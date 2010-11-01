require 'rake'
require 'rake/tasklib'

require 'set'
require 'pathname'

module CouchClient
  class RakeTask < ::Rake::TaskLib
    class MissingCouchClientConnection < Exception; end
    
    attr_accessor :connection, :design_path
    
    def initialize(&block)
      instance_eval(&block) if block_given?
      
      begin
        @connection ||= Object.const_get("Couch")
      rescue NameError
        raise MissingCouchClientConnection.new("specify a CouchClient connection within your RakeTask setup.")
      end
      
      @design_path = Pathname(@design_path || './designs')
      
      namespace :couch do
        desc "Syncs design documents with the database."
        task :sync do
          saved_design_docs = @connection.all_design_docs("include_docs" => true)
          local_design_docs = {}
          
          doctor = lambda do |path|
            path_breadcrumbs = path.to_s.split("/")[1..-1]
            path_hash_follow = path_breadcrumbs.reduce(""){|memo, key| memo + "['#{key}']" }
            
            if path.directory?
              eval("local_design_docs#{path_hash_follow} = {}")
              
              # Reject hidden filenames (filesnames that begin with a ".")
              path.children.reject{|p| p.basename.to_s.match(/^\./)}.each do |child|
                doctor.call(child)
              end
            else
              eval("local_design_docs#{path_hash_follow} = #{path.read.inspect}")
            end
          end
          
          doctor.call(@design_path)
          
          saved_ids = saved_design_docs.map{|doc| doc["id"].gsub(/^_design\//, "")}.to_set
          local_ids = local_design_docs["designs"].keys.to_set
          
          doc_ids_to_create = local_ids.difference(saved_ids).to_a
          doc_ids_to_update = saved_ids.intersection(local_ids).to_a
          doc_ids_to_delete = saved_ids.difference(local_ids).to_a
          
          doc_ids_to_create.each do |id|
            new_doc = @connection.build
            new_doc.id = "_design/#{id}"
            new_doc.merge!(local_design_docs["designs"][id])
            new_doc.merge!({"language" => "javascript"})
            
            puts "Creating: #{new_doc.id} at #{(new_doc.save and new_doc.rev)}"
          end
          
          doc_ids_to_update.each do |id|
            old_doc = saved_design_docs.detect{|d| d["id"] == "_design/#{id}"}["doc"]
            
            new_doc = @connection.build
            new_doc.id  = old_doc.id
            new_doc.rev = old_doc.rev
            new_doc.merge!(local_design_docs["designs"][id])
            new_doc.merge!({"language" => "javascript"})
            
            if old_doc == new_doc
              puts "Keeping:  #{new_doc.id} at #{new_doc.rev}"
            else
              puts "Updating: #{new_doc.id} to #{(new_doc.save and new_doc.rev)}"
            end
          end
          
          doc_ids_to_delete.each do |id|
            old_doc = saved_design_docs.detect{|d| d["id"] == "_design/#{id}"}["doc"]
            
            puts "Deleting: #{old_doc.id} on #{(old_doc.delete! and old_doc.rev)}"
          end
        end
        
        desc "Creates the database."
        task :create do
          resp = @connection.database.create
          if resp["ok"]
            puts "Created."
          else
            puts "The database could not be created, the file already exists."
          end
        end
        
        desc "Deletes the database and all its data."
        task :delete do
          resp = @connection.database.delete!
          
          if resp["ok"]
            puts "Deleted."
          else
            puts "The database could not be deleted, the file does not exist."
          end
        end
        
        desc "Compacts the database."
        task :compact do
          resp = @connection.database.compact!
          
          if resp["ok"]
            puts "Compaction Complete."
          else
            utils_uri = lambda {
              handler = handler = @connection.hookup.handler
              handler.uri.gsub(/#{handler.database}$/, "_utils")
            }.call
            
            puts "The database could not be compacted, see #{utils_uri} for more information."
          end
        end
      end
    end
  end
end