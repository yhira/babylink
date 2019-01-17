# encoding: utf-8
require 'pp'
require 'uri'
require 'kconv'

module AmazonHelper
  def make_amazon_links(items)
    results = '<h2>検索結果</h2>'
    #return
    items.each do |i|
#      results << make_baby_link(i, %|<a href="/?asin=#{i[:asin]}" class="btn btn-xs btn-danger"><span class="glyphicon glyphicon-tags"></span>　この商品のリンクを作る</a>|) << '<br />'
      results << make_baby_link(i, link_to(raw('<span class="glyphicon glyphicon-tags"></span>　この商品のリンクを作る'), root_path(asin: i[:asin]), remote: true, class: 'btn btn-xs btn-danger', onclick: "$('#spin').spin();")) << '<br />'
    end
    raw results.gsub("#{cookies[:aid]}/", '')
  end

  def make_baby_links(item)
    raw <<-EOF
      <h2>ブログパーツ</h2>
      <h3>シンプル</h3>
      #{make_baby_link(item)}
      #{text_area_tag 'tag', make_baby_link(item), class: 'form-control', onclick: 'this.select();', style: 'margin-bottom: 30px;'}
      <!--
      <h3>シンプル＋商品検索</h3>
      #{make_baby_link(item, 'search')}
      #{text_area_tag 'tag', make_baby_link(item, 'search'), class: 'form-control', onclick: 'this.select();', style: 'margin-bottom: 30px;'}
      -->
      <h3>商品説明入り</h3>
      #{make_baby_link(item, '【ここに商品の説明を記入する】')}
      #{text_area_tag 'tag', make_baby_link(item, '【ここに商品の説明を記入する】'), class: 'form-control', onclick: 'this.select();', style: 'margin-bottom: 30px;'}
      <h3>画像＋テキスト</h3>
      #{make_image_text_link(item)}
      #{text_area_tag 'tag', make_image_text_link(item), class: 'form-control', onclick: 'this.select();', style: 'margin-bottom: 30px;'}
      <h3>テキスト＋画像</h3>
      #{make_text_image_link(item)}
      #{text_area_tag 'tag', make_text_image_link(item), class: 'form-control', onclick: 'this.select();', style: 'margin-bottom: 30px;'}
      <h3>画像のみ</h3>
      #{make_image_link(item)}
      #{text_area_tag 'tag', make_image_link(item), class: 'form-control', onclick: 'this.select();', style: 'margin-bottom: 30px;'}
      <h3>テキストのみ</h3>
      #{make_text_link(item)}
      #{text_area_tag 'tag', make_text_link(item), class: 'form-control', onclick: 'this.select();', style: 'margin-bottom: 30px;'}
    EOF
  end

  def make_text_link(item)
    i = item
    %|<a href="#{i[:affiliate_url]}" rel="nofollow" target="_blank">#{i[:title]}</a>|
  end

  def make_image_link(item)
    i = item
    small_image_url = 'http://ec1.images-amazon.com/images/G/09/nav2/dp/no-image-avail-tny.gif'
    small_image_width = '65'
    small_image_height = '65'
    if i[:small_image]
      small_image_url = i[:small_image]['URL']
      small_image_width = i[:small_image]['Width']
      small_image_height = i[:small_image]['Height']
    end
    %|<a href="#{i[:affiliate_url]}" rel="nofollow" target="_blank"><img style="border-top: medium none; border-right: medium none; border-bottom: medium none; border-left: medium none;" src="#{small_image_url.sub('http://ecx.images-amazon.com', 'https://images-fe.ssl-images-amazon.com')}" width="#{small_image_width}" height="#{small_image_height}" /></a>|
  end

  def make_image_text_link(item)
    s = <<-EOF
      #{make_image_link(item)}<br />
      #{make_text_link(item)}
    EOF
    s.gsub(/^ +/, "").gsub("\n", '')
  end

  def make_text_image_link(item)
    s = <<-EOF
      #{make_text_link(item)}<br />
      #{make_image_link(item)}
    EOF
    s.gsub(/^ +/, "").gsub("\n", '')
  end

  def make_baby_link(item, description = '')
    i = item
    image_link = make_image_link(i)
    manufacturer = i[:author]
    manufacturer = i[:manufacturer] if manufacturer.blank?
    if description == 'search'
      search_tag = %|<div class="babylink-search" style=""><span style="padding:0 3px;background-color:#00428C;font-weight:bold;margin-right:3px;color:#ffffff;border-radius:3px;">a</span><span class="babylink-amazon-search" style="margin-right:15px"><a title="Amazonで検索" target="_blank" rel="nofollow"  href="http://www.amazon.co.jp/gp/search?keywords=#{URI.escape(cookies[:query].tosjis )}&__mk_ja_JP=%83J%83%5E%83J%83i&tag=#{@associate_tag}">Amazon</a></span><span class="babylink-rakuten-search"><a href="Amazonで検索"></a><span style="padding:0 3px;background-color:#BD0000;font-weight:bold;margin-right:3px;color:#ffffff;border-radius:3px;">R</span><span class="babylink-rakuten-search"><a title="楽天市場で検索" target="_blank" rel="nofollow"  href="">楽天市場</a></span>|
    elsif description.present?
      description_tag = %|<div class="babylink-description" style="margin-top: 7px;">#{description}</div>|
    end
    #tag = "#{i[:affiliate_url]}<br>"
    tag = <<-EOF
<div class="babylink-box" style="overflow: hidden; font-size: small; zoom: 1; margin: 15px 0; text-align: left;">
  <div class="babylink-image" style="float: left; margin: 0px 15px 10px 0px; width: 75px; height: 75px; text-align: center;">#{image_link}</div>
  <div class="babylink-info" style="overflow: hidden; zoom: 1; line-height: 120%;">
    <div class="babylink-title" style="margin-bottom: 2px; line-height: 120%;"><a href="#{i[:affiliate_url]}" rel="nofollow" target="_blank">#{i[:title]}</a></div>
    <div class="babylink-manufacturer" style="margin-bottom: 5px;">#{manufacturer}</div>
    #{search_tag}
    #{description_tag}
  </div>
  <div class="booklink-footer" style="clear: left"></div>
</div>
    EOF
    tag.gsub(/^ +/, "").gsub("\n", '')
  end
end
