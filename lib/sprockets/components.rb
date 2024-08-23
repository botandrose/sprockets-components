# frozen_string_literal: true

require "sprockets/railtie"

module Sprockets
  module Components
    class Railtie < ::Rails::Railtie
      initializer "sprockets-components", group: :all do |app|
        Sprockets::DirectiveProcessor.include Directives
        app.config.assets.configure do |env|
          env.register_pipeline :component, Pipeline.new
        end

        # there isn't a supported way to register path resolvers so we have to hack it in
        Sprockets::Resolve.prepend Module.new {
          def resolve_under_paths(*)
            @resolvers ||= [
              method(:resolve_main_under_path),
              method(:resolve_alts_under_path),
              method(:resolve_index_under_path),
              method(:resolve_component),
            ]
            super
          end

          def resolve_component load_path, logical_name, mime_exts
            dirname = File.join(load_path, logical_name)

            if load_path.split("/").last == "components" && Dir.exist?(dirname)
              candidates = [{
                filename: "#{dirname}/#{logical_name}.js",
                type: "application/javascript",
                index_alias: "app/assets/components/#{logical_name}.js",
              }]
            else
              candidates = []
            end

            return candidates, [ URIUtils.build_file_digest_uri(dirname) ]
          end
        }
      end
    end

    module Directives
      protected

      def process_component_directive
        name = @dirname.split("/").last
        process_component_css_directive "./#{name}.css"
        process_component_html_directive "./#{name}.html"
      end

      def process_component_css_directive path
        @required << resolve(path, accept: "text/css", pipeline: :component)
      end

      def process_component_html_directive path
        @required << resolve(path, accept: "text/html", pipeline: :component)
      end
    end

    class Pipeline
      def call env, type, file_type
        {
          "text/css" => [CSSProcessor.new],
          "text/html" => [HTMLProcessor.new],
        }.fetch(type) +
          env.send(:default_processors_for, type, file_type)
      end
    end

    class CSSProcessor
      def call input
        "const __SprocketsComponent__CSS = `#{input[:data]}`;\n"
      end
    end

    class HTMLProcessor
      def call input
        "const HTML = `<style>${__SprocketsComponent__CSS}</style>\n#{input[:data]}`;\n"
      end
    end
  end
end

