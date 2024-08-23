
curl -X POST \
     -H "X-Algolia-API-Key: ${AlgoliaAPIKey}" \
     -H "X-Algolia-Application-Id: ${AlgoliaApplicationId}" \
     --data-binary '{"params":"hitsPerPage=10&attributesToRetrieve=*&filters=&sortFacetValuesBy=count&aroundLatLngViaIP=true&numericFilters=createdAt<unixTimestampNow&getRankingInfo=true"}' \
     "https://${AlgoliaApplicationId}-dsn.algolia.net/1/indexes/selling_items_index?query"

