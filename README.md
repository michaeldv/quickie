## Quickie ##
Quickie is micro library for quick in-place testing of your Ruby code. It adds three
useful methods: <code>Object#should</code> and <code>Object#should\_not</code> for
positive and negative assertions, and <code>Object#stub</code> for method stubbing.

With Quickie you can conveniently bundle tests along with your Ruby code, typically
within <code>if $0 == \_\_FILE\_\_</code> conditional statement.

### System Requirements ###
Ruby 1.9.2 or later.

### Installation ###
    # Installing as Ruby gem
    $ gem install quickie

    # Cloning the repository
    $ git clone git://github.com/michaeldv/quickie.git

### Usage Example - Assertions ###

    $ cat > 1.rb
    class Account                             # Back account class.
      attr_reader :balance                    # Current account balance.
      
      def initialize(amount = 0)              # Open the account.
        @balance = amount.abs                 # Accept initial deposit.
      end
      
      def deposit(amount)                     # Accept a deposit.
        @balance += amount.abs                # Update current balance.
      end
      
      def status                              # Display account status.
        "Current balance: $#{balance}"
      end
    end

    if $0 == __FILE__                         # Execute only when running current Ruby file.
      require "quickie"                       # Require the gem.
      
      acc = Account.new(100)                  # Deposit $100 when opening the account.
      acc.balance.should == 100               # Initial balance should be $100.
      acc.deposit(200)                        # Deposit $200 more.
      acc.balance.should != 100               # The balance should get updated.
      acc.balance.should == 300               # $100 + $200 = $300.
      
      String.should === acc.status            # Account#status returns a string.
      acc.status.should_not =~ /\$$/          # Status string should contain the balance.
      acc.status.should =~ /\$\d+\.*\d*$/     # Balance contains digits with optional separator.
    end
    ^D
    $ ruby 1.rb
    ......
    
    Passed: 6, not quite: 0, total tests: 6.

### Usage Example - Method Stubs ###
To set up a stub with optional return value use <code>obj.stub(:method, :return => value)</code>.
To remove existing stub and restore original method use <code>obj.stub(:method, :remove)</code>.

    $ cat > 2.rb
    require "net/http"
    require "json"
    require "uri"
    
    class GemStats                            # Get gems stats from rubygems.org.
      attr_reader :downloads
      
      def initialize(gem, version)
        uri = URI.parse("http://rubygems.org/api/v1/downloads/#{gem}-#{version}.json")
        response = Net::HTTP.get_response(uri)
        @downloads = JSON.parse(response.body)
      end
      
      def total
        @downloads["total_downloads"]
      end
      
      def version
        @downloads["version_downloads"]
      end
    end
    
    if $0 == __FILE__
      require "quickie"

      response = { :total_downloads => 999_999, :version_downloads => 999 }.to_json
      response.stub(:body, :return => response)
      Net::HTTP.stub(:get_response, :return => response)
      
      stats = GemStats.new(:awesome_print, '1.0.2')
      
      Hash.should === stats.downloads         # Downloads should ba a hash.
      stats.downloads.keys.size.should == 2   # It should have two keys.
      stats.total.should == 999_999           # Total downloads should match test data.
      stats.version.should == 999             # Ditto for version.
    end
    ^D
    $ ruby 2.rb 
    ....
        
    Passed: 4, not quite: 0, total tests: 4.

### Testing Quickie ###
Quickie code is tested by the Quickie itself.

    $ ruby test/quickie_test.rb
    ................................
    
    Passed: 32, not quite: 0, total tests: 32.

### Note on Patches/Pull Requests ###
* Fork the project on Github.
* Make your feature addition or bug fix.
* Add test for it, making sure $ ruby test/*.rb all pass.
* Commit, do not mess with Rakefile, version, or history.
* Send me a pull request.

### License ###

    Copyright (c) 2011-12 Michael Dvorkin
    twitter.com/mid
    %w(mike dvorkin.net) * "@" || %w(mike fatfreecrm.com) * "@"
    Released under the MIT license. See LICENSE file for details.
