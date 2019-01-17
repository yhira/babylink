# encoding: utf-8
require 'amazon/ecs'
require 'pp'

ASSOCIATE_TAG = 'ASSOCIATE_TAG'

Amazon::Ecs.options = {
  AWS_access_key_id: 'AWS_ACCESS_KEY_ID',
  AWS_secret_key: 'AWS_SECRET_KEY',
  response_group: 'Medium,ItemAttributes',#,SalesRank,Reviews',
  condition: 'All',
  merchant_id: 'All',
  country: 'jp',
}

class AmazonController < ApplicationController
  def index
    #cookies.permanent[:aid] = nil
    p_aid = params[:aid] if params[:aid].present?
    c_aid = cookies[:aid] if cookies[:aid].present?
    @associate_tag = p_aid || c_aid || ASSOCIATE_TAG
    if @associate_tag.present?
      if (/[0-9a-zA-Z-]+-22/ !~ @associate_tag) && params[:aid]
        redirect_to amazon_setup_path, alert: 'AmazonのトラッキングIDの書式が違います。'
        return
      end
      cookies.permanent[:aid] = @associate_tag
    end

    #cookies.permanent[:rid] = nil
    p_rid = params[:rid] if params[:rid].present?
    c_rid = cookies[:rid] if cookies[:rid].present?
    @rakuten_tag = p_rid || c_rid || nil
    if @rakuten_tag.present?
      cookies.permanent[:rid] = @rakuten_tag
    end


    @query = params[:q]
    cookies.permanent[:query] = @query if @query.present?
    if @query.present?
      @items = []
      res = Amazon::Ecs.item_search(@query, search_index: 'All', associate_tag: @associate_tag)
      res.items.each do |item|
        @items << item_to_hash(item, @associate_tag)
      end
      #pp @items
    end
    asin = params[:asin]
    if asin.present?
      if @associate_tag == ASSOCIATE_TAG
        flash.now[:alert] = 'AmazonのトラッキングIDが設定されていません。'
      end
      res = Amazon::Ecs.item_search(asin, search_index: 'All', associate_tag: @associate_tag)
      #p '************************************'
      if res.error
        redirect_to root_url, alert: res.error
      else
        @item = item_to_hash(res.items[0], @associate_tag)
      end
    end

  end

  def setup
    @associate_tag = params[:aid] || cookies[:aid]
    @rakuten_tag = params[:rid] || cookies[:rid]
    @associate_tag = nil if @associate_tag == ASSOCIATE_TAG
  end

  def clear
    cookies.permanent[:aid] = nil
    redirect_to amazon_setup_path
  end

  def raku_clear
    cookies.permanent[:rid] = nil
    redirect_to amazon_setup_path
  end

  private
  def item_to_hash(item, associate_tag)
    element = item.get_element('ItemAttributes')
    associate_tag ||= ASSOCIATE_TAG
    {
      asin: item.get('ASIN'),
      title: element.get("Title"),
      page_url: "http://www.amazon.co.jp/dp/#{item.get('ASIN')}/",
      affiliate_url: "http://www.amazon.co.jp/exec/obidos/ASIN/#{item.get('ASIN')}/#{associate_tag}/",
      isbn: element.get("ISBN"),
      author: element.get_array("Author").join(", "),
      product_group: element.get("ProductGroup"),
      manufacturer: element.get("Manufacturer"),
      publication_date: element.get("PublicationDate"),

      # URL, Width, Heightの要素を持っている
      small_image: item.get_hash("SmallImage"),
      medium_image: item.get_hash("MediumImage"),
      large_image: item.get_hash("LargeImage")
    }
    #Amazonでの個別商品のURL（dp）とアフィリエイトリンク（exec/obidos/ASIN）は違いますね｜linker journal｜linker
    #http://linker.in/journal/2012/10/amazonurldpexecobidosasin.php
  end
end
