function(doc) {
  var ret = new Document();
  ret.add(doc.name, {'store':'yes'});
  ret.add(doc.city, {'store':'yes'});
  return ret;
}