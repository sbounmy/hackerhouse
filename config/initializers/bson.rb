module BSON
   # Removes wrapping of id
   # Otherwise it becomes { "$oid": "536bf5a4632d3293b7010000" }
   # rails-api/active_model_serializers/issues/354
   class ObjectId
     alias :to_json :to_s
     alias :as_json :to_s
   end
 end