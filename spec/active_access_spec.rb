require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'active_model'

describe "ActiveAccess::AttributeMethods" do

  context "given an ActiveModel class" do

    let(:abstract_base_class) do
      Class.new(Struct.new(:foo, :bar, :baz)).tap do |klass|
        klass.class_eval do

          include ActiveModel::AttributeMethods
          include ActiveAccess::AttributeMethods

          def attributes
            members.each_with_object({}) { |m, h| h[m.to_s] = self[m] }
          end

          alias_method :attribute, :[]

        end
      end
    end

    let(:model_instance) { model_class.new("fooh", "bhar", "bazh") }

    let(:private_attribute)       { :bar   }
    let(:private_attribute_value) { "bhar" }

    let(:private_reader) { :"#{private_attribute}"  }
    let(:private_writer) { :"#{private_attribute}=" }

    shared_examples_for "any ActiveModel class with private attributes" do

      it "prevents public reads with named reader on private attributes" do
        lambda { model_instance.public_send(private_reader) }.
          should raise_error(NoMethodError, /private/)
      end

      it "prevents public writes with named writer on private attributes" do
        lambda { model_instance.public_send(private_writer,"changed") }.
          should raise_error(NoMethodError, /private/)
      end

      it "allows private reads with named reader on private attributes" do
        model_instance.send(private_reader).
          should == private_attribute_value
      end

      it "allows private writes with named writer on private attributes" do
        model_instance.send(private_writer, "changed")
        model_instance.send(private_reader).should == "changed"
      end

      it "allows read access to private attributes via unnamed reader" do
        model_instance[private_attribute].should == private_attribute_value
      end

      it "allows read access to private attributes via unnamed reader" do
        model_instance[private_attribute] = "changed"
        model_instance[private_attribute].should == "changed"
      end

    end

    shared_examples_for "any ActiveModel class" do

      it_should_behave_like "any ActiveModel class with private attributes"

      it "allows public reads on public (default) attributes" do
        model_instance.foo.should == "fooh"
      end

      it "allows public writes to public (default) attributes" do
        model_instance.foo = "fhoo"
        model_instance.foo.should == "fhoo"
      end

    end

    context "when private attributes are declared before methods" do

      let(:model_class) do
        Class.new(abstract_base_class).tap do |klass|
          klass.class_eval do
            attr_private :bar
            define_attribute_methods([:foo, :bar, :baz])
          end
        end
      end

      it_should_behave_like "any ActiveModel class"

    end

    context "when attribute methods are declared before privacy" do

      let(:model_class) do
        Class.new(abstract_base_class).tap do |klass|
          klass.class_eval do
            define_attribute_methods([:foo, :bar, :baz])
            attr_private :bar
          end
        end
      end

      it_should_behave_like "any ActiveModel class"

    end

    context "when attributes are inherited " do

      let(:base_class) do
        Class.new(abstract_base_class).tap do |klass|
          klass.class_eval do
            define_attribute_methods([:foo, :bar])
            attr_private :bar
          end
        end
      end

      let(:model_class) do
        Class.new(base_class).tap do |klass|
          klass.class_eval do
            define_attribute_methods([:baz])
            attr_private :baz
          end
        end
      end

      context "with inherited private attributes" do
        it_should_behave_like "any ActiveModel class"
      end

      context "with derived private attributes" do
        let(:private_attribute)       { :baz   }
        let(:private_attribute_value) { "bazh" }
        it_should_behave_like "any ActiveModel class"
      end
    end

  end
end

