module Fit
  class File
    class Data < BinData::Record

      class_attribute :global_message_number, :instance_writer => false

      def self.generate(definition)
        message_number = definition.global_message_number.snapshot
        type = Definitions.get_name(message_number) || "data_record_#{message_number}"

        Class.new(self) do
          self.global_message_number = message_number

          endian definition.endianness

          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def record_type
              :#{type}
            end
          RUBY

          definition.fields.each do |field|
            code = ""

            # in case the field size is a multiple of the field length, we must build an array
            if (field.type != "string" && field.size > field.length)
              code << "array :#{field.raw_name}, :type => :#{field.type}, :initial_length => #{field.size/field.length}\n"
            else
              # string are not null terminated when they have exactly the lenght of the field
              code << "#{field.type} :#{field.raw_name}"
              if field.type == "string"
                code << ", :read_length => #{field.size}, :trim_padding => true"
              end
              code << "\n"
            end

            code << "def #{field.name}\n"

            if field.scale && field.scale != 1
              code << "scale = #{field.scale.inspect}.0\n"
            else
              code << "scale = nil\n"
            end

            if field.dyn_data
              code << "dyn = #{field.dyn_data}\n"
            else
              code << "dyn = nil\n"
            end
            code << <<-RUBY
                get_value #{field.raw_name}.snapshot, '#{field.real_type}', scale, dyn
              end
            RUBY

            class_eval code , __FILE__, __LINE__ + 1
          end
      
          private
            # return the dynamic value if relevant
            # otherwise, it returns value (scaled if necessary)
            def get_value raw_value, raw_type, raw_scale, dyn_data
              val = get_dyn_value(dyn_data, raw_value)
              return val unless val.nil?

              if raw_scale
                if raw_value.is_a? Enumerable
                  raw_value.map { |elt| elt / raw_scale }
                else
                  raw_value / raw_scale
                end
              else
                raw_value
              end
            end

            def get_dyn_value dyn_data, raw_value
              return nil if dyn_data.nil?

              dyn_data.each do |key, dyn|
                # make sure method exist before calling send (all fields are not always defined)
                if  self.respond_to?("raw_#{dyn[:ref_field_name]}") &&
                    dyn[:ref_field_values].include?(self.send("raw_#{dyn[:ref_field_name]}"))
              
                  return raw_value
                end
              end
              nil
            end

        end
      end

    end
  end
end
