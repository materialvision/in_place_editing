module InPlaceEditing
  def self.included(base)
    base.extend(ClassMethods)
  end

  # Example:
  #
  #   # Controller
  #   class BlogController < ApplicationController
  #     in_place_edit_for :post, :title
  #   end
  #
  #   # View
  #   <%= in_place_editor_field :post, 'title' %>
  #
  module ClassMethods
    
    def is_textiled_field?(object, attribute)
      klass = object.to_s.camelize.constantize
      klass.respond_to?('textiled_attributes') and klass.textiled_attributes.member?(attribute.to_sym)
    end
    
    def in_place_edit_for(object, attribute, options = {})

      define_method("set_#{object}_#{attribute}") do
        unless [:post, :put].include?(request.method) then
          return render(:text => 'Method not allowed', :status => 405)
        end
        @item = object.to_s.camelize.constantize.find(params[:id])
        @item.update_attribute(attribute, params[:value])

        if self.class.is_textiled_field?(object, attribute)
          render :text => @item.send(attribute).to_s
        else
          render :text => CGI::escapeHTML(@item.send(attribute).to_s)
        end

      end

      if is_textiled_field?(object, attribute)
        define_method("get_#{object}_#{attribute}_source") do
          unless [:get].include?(request.method)  then
            return render(:text => 'Method not allowed', :status => 405)
          end
          @item = object.to_s.camelize.constantize.find(params[:id])
          render :text => @item.send(attribute.to_s + '_source')
        end
      end

    end

  end
end
