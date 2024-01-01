# frozen_string_literal: true

require_relative "components/version"

module Sprockets
  module Components
    class Engine < ::Rails::Engine
      initializer "sprockets-components" do |app|
        Sprockets::DirectiveProcessor.include Directives
        app.config.after_initialize do
          app.assets.register_pipeline :component, Pipeline.new
        end
      end
    end

    module Directives
      protected

      def process_component_directive name
        process_component_css_directive "#{name}/#{name}.css"
        process_component_html_directive "#{name}/#{name}.html"
        process_component_js_directive "#{name}/#{name}.js"
      end

      def process_component_css_directive path
        @required << resolve(path, accept: "text/css", pipeline: :component)
      end

      def process_component_html_directive path
        @required << resolve(path, accept: "text/html", pipeline: :component)
      end

      def process_component_js_directive path
        @required << resolve(path, accept: "application/javascript", pipeline: :component)
      end
    end

    class Pipeline
      def call env, type, file_type
        {
          "text/css" => [CSSProcessor.new],
          "text/html" => [HTMLProcessor.new],
          "application/javascript" => [JSProcessor.new],
        }.fetch(type) +
          env.send(:default_processors_for, type, file_type)
      end
    end

    class CSSProcessor
      def call input
        "const CSS = `#{input[:data]}`;\n"
      end
    end

    class HTMLProcessor
      def call input
        "const HTML = `<style>${CSS}</style>\n#{input[:data]}`;\n"
      end
    end

    class JSProcessor
      def call input
        name = input[:name].split("/").first
        "#{input[:data]};window.customElements.define('#{name}', #{name.underscore.classify})"
      end
    end
  end
end

