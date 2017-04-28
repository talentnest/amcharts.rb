module AmCharts
  module AmChartsHelper
    def amchart(chart, container)
      # Load necessary JS and CSS files, without loading one more than once
      @loaded_amchart_files ||= { js: [], css: []}

      js_files = ['amcharts', "amcharts/#{chart.type}"]
      js_files << "amcharts/lang/#{chart.language}" if chart.language?

      css_files = ['amcharts']

      if chart.export?
        chart.export.settings.libs = { autoLoad: false } # Turn off automatic loading of libraries

        export_dir = 'amcharts/plugins/export'

        # For any export
        js_files << "#{export_dir}/export.min"
        js_files << "#{export_dir}/libs/fabric.js/fabric.min"

        # Used to offer download files
        js_files << "#{export_dir}/libs/FileSaver.js/FileSaver.min"

        # For PDF format
        js_files << "#{export_dir}/libs/pdfmake/pdfmake"
        js_files << "#{export_dir}/libs/pdfmake/vfs_fonts"

        # For XLSX format
        js_files << "#{export_dir}/libs/jszip/jszip.min"
        js_files << "#{export_dir}/libs/xlsx/xlsx"

        # Language support
        js_files << "#{export_dir}/lang/#{chart.language}" if chart.language?

        # CSS
        css_files << "#{export_dir}/export"
      end

      js_files -= @loaded_amchart_files[:js]
      css_files -= @loaded_amchart_files[:css]

      @loaded_amchart_files[:js] += js_files
      @loaded_amchart_files[:css] += css_files

      content_for(:javascript) { javascript_include_tag(*js_files) }
      content_for(:stylesheets) { stylesheet_link_tag(*css_files) }

      # Render the chart builder
      builder = AmCharts::ChartBuilder.new(chart, self)
      chart.container = container
      javascript_tag do
        builder.render_js('chart_builder', template_type: :file, locals: { chart: chart, container: container })
      end
    end
  end
end
