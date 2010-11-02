function(doc) {
  var ret = new Document();
  ret.add(doc.name, {'store':'yes'});
  return ret;
}