function(newDoc, savedDoc, userCtx) {
  if(newDoc._deleted) return;
  if(!newDoc.name) {
    throw({"forbidden": "Document must have a name field."});
  }
}