require_relative '../helper'

describe "A Domain" do
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
    @soa.name.should.not.be.nil
  end

  should 'have some records' do
    @domain.records.count.should.not.equal 0
  end

  should 'not accept being created twice' do
    should.raise(Sequel::DatabaseError) {
      Domain.create(:name => 'example.com', :type => 'MASTER')
    }
    #puts message 
    #message.should =~ /entry already exist/
  end

  should 'have only one SOA' do
    # check that adding another SOA fails
    false.should.equal true
  end

  should 'return serial from SOA' do
    @domain.soa(:serial).should.equal 2006090501
  end

  should 'return refresh from SOA' do
    @domain.soa(:serial).should.equal 7200
  end

  should 'return retry from SOA' do
    @domain.soa(:retry).should.equal 3600
  end

  should 'return expiry from SOA' do
    @domain.soa(:expiry).should.equal 4800
  end

  should 'return minimum from SOA' do
    @domain.soa(:minimum).should.equal 86400
  end
end

