#require File.expand_path('../../spec/helper', __FILE__)
#require 'helper'

describe "A Record" do
  behaves_like :rack_test

  before do
    clean = Domain[:name => 'example.com']
    clean.destroy unless clean.nil?
    
    @domain = Domain.create(:name => 'example.com', :type => 'MASTER')
    @record = Record.create(:domain_id => @domain.id, :name => 'www.example.com', :type => 'A',
                     :content => '10.10.10.10', :ttl => 1234)
    @soa = Record.create(:domain_id => @domain.id, :name => 'example.com', :type => 'SOA',
                  :content => 'ns0.erasme.org postmaster.erasme.org 2006090501 7200 3600 4800 86400',
                  :ttl => 4321)
  end

  after do
    @record.destroy
    @soa.destroy
    @domain.destroy
  end

  should 'have a name' do
    @record.name.should.not.be.nil
  end

  should 'have an associated domain' do
    @record.domain_id.should.equal @domain.id
  end 

end

