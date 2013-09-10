require 'pubmed_api'

class SearchController < ApplicationController
  before_filter :authenticate_user!  

  def result
    retmax = 10
    @retstart = params[:retstart]
    pub = Search.new #(params[:queri], 10)
    pub.epall.keyword = params[:queri]
    pub.epall.retmax = retmax
    
    case params[:page]
    when 'next'
      @retstart = @retstart.to_i + retmax
      
    when 'prev'
      @retstart = @retstart.to_i - retmax
      
    else
      # save queri record
      record = SearchRecord.new({:queri => params[:queri], :username => current_user.username} )
      record.save
    
    end
  
    pub.epall.esearch.retstart = @retstart
    @articles = pub.search
    
    #rankning
    querifreq = QueriRanking.where(:queri => params[:queri])
    case querifreq
    when []
      QueriRanking.create({:queri => params[:queri], :freq => 1})
      
    else
      querifreq.each do |qf|
        qf.update_attribute(:freq, qf.freq+1)
      end
    end
      
  end
  
  def index
    @record = SearchRecord.find(:all, :conditions => {:username => current_user.username} )
    @record.reverse!
    
  end
  
  def attestation
    if params[:logout]
      redirect_to search_index_path
    end
     
    att = Attestation.new
    att.requestId = params[:userid]
    att.requestPass = params[:password]
    
    @att_sent = att.attestation
    if att.username
      redirect_to search_index_path(:uname => att.username)
    end
    
  end
    
  def newuser
    @user = UserAttestation.new({:user_id => params[:userid], :password => params[:password]})
    @user.save
    
    redirect_to search_index_path
    
  end
    
  def detail
    fetch = Detail.new
    fetch.efetch.id = params[:pid]
    
    @details = fetch.do
    
  end
    
end
