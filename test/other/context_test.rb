require File.join(File.dirname(__FILE__), '..', 'test_helper')

class ContextTest < Test::Unit::TestCase # :nodoc:
  
  def self.context_macro(&blk)
    context "with a subcontext made by a macro" do
      setup { @context_macro = :foo }

      merge_block &blk 
    end
  end

  # def self.context_macro(&blk)
  #   context "with a subcontext made by a macro" do
  #     setup { @context_macro = :foo }
  #     yield # <- this doesn't work.
  #   end
  # end

  context "context with setup block" do
    setup do
      @blah = "blah"
    end
    
    should "run the setup block" do
      assert_equal "blah", @blah
    end
    
    should "have name set right" do
      assert_match(/^test: context with setup block/, self.to_s)
    end

    context "and a subcontext" do
      setup do
        @blah = "#{@blah} twice"
      end
      
      should "be named correctly" do
        assert_match(/^test: context with setup block and a subcontext should be named correctly/, self.to_s)
      end
      
      should "run the setup blocks in order" do
        assert_equal @blah, "blah twice"
      end
    end

    context_macro do
      should "have name set right" do
        assert_match(/^test: context with setup block with a subcontext made by a macro should have name set right/, self.to_s)
      end

      should "run the setup block of that context macro" do
        assert_equal :foo, @context_macro
      end

      should "run the setup block of the main context" do
        assert_equal "blah", @blah
      end
    end

  end

  context "another context with setup block" do
    setup do
      @blah = "foo"
    end
    
    should "have @blah == 'foo'" do
      assert_equal "foo", @blah
    end

    should "have name set right" do
      assert_match(/^test: another context with setup block/, self.to_s)
    end
  end
  
  context "context with method definition" do
    setup do
      def hello; "hi"; end
    end
    
    should "be able to read that method" do
      assert_equal "hi", hello
    end

    should "have name set right" do
      assert_match(/^test: context with method definition/, self.to_s)
    end
  end
  
  context "another context" do
    should "not define @blah" do
      assert_nil @blah
    end
  end
    
  context "context with multiple setups and/or teardowns" do
    
    cleanup_count = 0
        
    2.times do |i|
      setup { cleanup_count += 1 }
      teardown { cleanup_count -= 1 }
    end
    
    2.times do |i|
      should "call all setups and all teardowns (check ##{i + 1})" do
        assert_equal 2, cleanup_count
      end
    end
    
    context "subcontexts" do
      
      2.times do |i|
        setup { cleanup_count += 1 }
        teardown { cleanup_count -= 1 }
      end
                  
      2.times do |i|
        should "also call all setups and all teardowns in parent and subcontext (check ##{i + 1})" do
          assert_equal 4, cleanup_count
        end
      end
      
    end
    
  end
  
  should_eventually "pass, since it's unimplemented" do
    flunk "what?"
  end

  should_eventually "not require a block when using should_eventually"
  should "pass without a block, as that causes it to piggyback to should_eventually"
  
  context "context for testing should piggybacking" do
    should "call should_eventually as we are not passing a block"
  end

  context "context with basic setup" do
    setup do
      @magical_variable = ""
    end

    static_context "static context to stash a copy the parent context's state" do
      [:first, :seccond, :third].each_with_index do |n, index|
        should "the #{n} test should have #{index} chars in it" do
          assert_equal "." * index, @magical_variable
          @magical_variable << "."
        end
      end
    end

    [:first, :seccond, :third].each do |n|
      should "the #{n} test should be a blank string" do
        assert_equal "", @magical_variable
        @magical_variable << "."
      end
    end
  end

  context "a static context" do
    setup do
      @context = Shoulda::StaticContext.new("foo", nil){}
    end

    should "not allow us to setup a teardown" do
      assert !@context.respond_to?(:teardown)
    end

    should "not allow us to setup a should(.., :before) hook, as that would be silly" do
      assert_raise(ArgumentError) { @context.should("foo", :before => proc{}){} }
    end
  end

  static_context "static context with setup and teardown only run once" do
    setup do
      @@static_setup_var ||= 0
      @@static_setup_var += 1
      @instance_var ||= 0
      @instance_var += 1
    end

    [:first, :seccond].each do |n|
      should "have only run the setup once after the #{n} should" do
        assert_equal 1, @@static_setup_var
      end
    end

    [:first, :seccond].each do |n|
      should "have instance variables available in the #{n} should" do
        assert_equal 1, @instance_var
      end
    end

    context "but this dynamic context should be run more than once" do
      setup do
        @variable_context_var = 0
      end

      should "have access to the static context variables" do
        assert_equal 1, @instance_var
      end

      [:first, :seccond].each do |name|
        should "have it's own variables available and correctly set on the #{name} time" do
          @variable_context_var += 1
          assert_equal 1, @variable_context_var
        end
      end
    end
  end

  context "context" do
    context "with nested subcontexts" do
      should_eventually "only print this statement once for a should_eventually"
    end
  end
end
