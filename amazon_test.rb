require 'amazon/ecs'
require 'pp'

Amazon::Ecs.options = {
  associate_tag: 'ASSOCIATE_TAG',
  AWS_access_key_id: 'AWS_ACCESS_KEY_ID',
  AWS_secret_key: 'AWS_SECRET_KEY',
  response_group: 'Medium,ItemAttributes',#,SalesRank,Reviews',
  condition: 'All',
  merchant_id: 'All',
  country: 'jp',
}

## API呼び出し
#res = Amazon::Ecs.item_lookup("B00005RUUJ", :country => 'jp')
#
## 返ってきたXMLを表示（res.doc.to_sでも多分OK）
#puts res.marshal_dump

# "Ruby" で Amazon の商品を検索
res = Amazon::Ecs.item_search('EW1250P-W', search_index: 'All', sort: 'salesrank')
#res = Amazon::Ecs.item_search('', search_index: 'Music', artist: '相沢舞', sort: 'salesrank', item_page: 1, browse_node: 562032)
#
#puts res.marshal_dump
##pp resp.doc#.at('TotalResults').inner_text#.get('TotalResults')
##
res.items.each { |item|
#  puts item.get_elements("./ASIN")
  puts item.get("SalesRank")
  puts item.get("ItemAttributes/Title")
#  puts item.get_elements("ItemAttributes/Actor")
#  puts item.get_elements("Author")
#  puts item.get_element("DetailPageURL")
}

#all_offers_url
#
#
#tiny_image_url
#tiny_image_h
#tiny_image_w

