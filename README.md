## Quickie ##
Quickie is micro library for quick in-place testing of your Ruby code. It adds two useful
methods: <code>Object#should</code> and <code>Object#should\_not</code> for positive and
negative assertions. With Quickie you can conveniently bundle tests together with your
Ruby code, typically within <code>if $0 == \_\_FILE\_\_</code> conditional statement.

### System Requirements ###
Ruby 1.9.2 or later.

### Installation ###
    # Installing as Ruby gem
    $ gem install quickie

    # Cloning the repository
    $ git clone git://github.com/michaeldv/quickie.git

### Usage Example ###

    $ cat > sample.rb
    class Account                             # Back account class.
      attr_reader :balance                    # Current account balance.
      
      def initialize(amount)                  # Open the account.
        @balance = amount                     # Accept initial deposit.
      end
      
      def deposit(amount)                     # Accept account deposit.
        @balance += amount                    # Update current balance.
      end
      
      def withdraw(amount)                    # Withdraw from the account.
        cash = [ @balance, amount ].min       # Can't withdraw more than the balance.
        @balance -= cash                      # Update current balance.
        cash
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
      acc.balance.should == 300               # It should be $100 + $200 = $300.
      
      String.should === acc.status            # Account#status returns a string.
      acc.status.should_not =~ /\$$/          # Status string should contain the balance.
      acc.status.should =~ /\$\d+$/           # The balance is one or more digits.
      
      acc.withdraw(500).should == 300         # Withdrawal that exeeds the balance is not allowed.
      acc.balance.should == 0                 # Current balance should drop to zero.
      acc.status.should !~ /\$[1-9]+$/        # Status no longer shows positive number.
      acc.status.should =~ /\$0$/             # It shows $0.
    end
    ^D
    $ ruby sample.rb 
    ..........
    
    Passed: 10, not quite: 0, total tests: 10.

### Testing Quickie ###
Quickie code is tested by the Quickie itself.

    $ ruby test/quickie_test.rb
    ....................
    
    Passed: 20, not quite: 0, total tests: 20.

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
