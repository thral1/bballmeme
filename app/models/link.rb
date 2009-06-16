class Link < ActiveRecord::Base
  belongs_to :articles

  def get_referring_articles
    #logger.info "referring articles for #{self[:url]}: #{self[:articles].inspect}\n #{self.articles.inspect} \n#{articles.inspect} \n#{@articles.inspect}\n"
    logger.info "#{self.articles.count} referring articles for #{self[:url]}: #{self.articles.inspect}\n"
    self.articles
  end
end
