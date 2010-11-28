module Snorby
  
  module Report
    
    include Rails.application.routes.url_helpers # brings ActionDispatch::Routing::UrlFor
    include ActionView::Helpers::TagHelper
    
    def self.build_report(range='today')

      params = {:format => :pdf}
      params[:range] = range

      set_defaults(params[:range])

      @src_metrics = @cache.src_metrics
      @dst_metrics = @cache.dst_metrics

      @tcp = @cache.protocol_count(:tcp, params[:range].to_sym)
      @udp = @cache.protocol_count(:udp, params[:range].to_sym)
      @icmp = @cache.protocol_count(:icmp, params[:range].to_sym)
      @high = @cache.severity_count(:high, params[:range].to_sym)
      @medium = @cache.severity_count(:medium, params[:range].to_sym)
      @low = @cache.severity_count(:low, params[:range].to_sym)
      @sensor_metrics = @cache.sensor_metrics(params[:range].to_sym)

      @signature_metrics = @cache.signature_metrics

      @event_count = @cache.all.map(&:event_count).sum

      @axis = @sensor_metrics.last[:range].join(',') if @sensor_metrics.last

      @classifications = Classification.all(:order => [:events_count.desc])
      @sensors = Sensor.all(:limit => 5, :order => [:events_count.desc])
      @favers = User.all(:limit => 5, :order => [:favorites_count.desc])

      @last_cache = @cache.get_last ? @cache.get_last.ran_at : Time.now

      sigs = Event.all(:limit => 5, :order => [:timestamp.desc], :fields => [:sig_id], :unique => true).map(&:signature).map(&:sig_id)
      @recent_events = Event.all(:sig_id => sigs).group_by { |x| x.sig_id }.map(&:last).map(&:first)
      

      av = ActionView::Base.new(Rails.root.join('app', 'views'))
      av.assign({
        :start_time => @start_time,
        :end_time => @end_time,
        :cache => @cache,
        :src_metrics => @src_metrics,
        :dst_metrics => @dst_metrics,
        :tcp => @tcp,
        :udp => @udp,
        :icmp => @icmp,
        :high => @high,
        :medium => @medium,
        :low => @low,
        :sensor_metrics => @sensor_metrics,
        :signature_metrics => @signature_metrics,
        :event_count => @event_count,
        :axis => @axis,
        :last_cache => @last_cache
      })

      pdf = PDFKit.new(av.render(:template => "page/dashboard.pdf.erb", :layout => 'layouts/pdf.html.erb'))
      pdf.stylesheets << Rails.root.join("public/stylesheets/pdf.css")
      
      data = {
        :start_time => @start_time,
        :end_time => @end_time,
        :pdf => pdf.to_pdf
      }
      
      return data
    end

    private

      def self.set_defaults(range)

        case range.to_sym
        when :today
          @cache = Cache.today
          @start_time = Time.now.beginning_of_day
          @end_time = Time.now.end_of_day

        when :yesterday
          @cache = Cache.yesterday
          @start_time = (Time.now - 1.day).beginning_of_day
          @end_time = (Time.now - 1.day).end_of_day

        when :week
          @cache = DailyCache.this_week
          @start_time = Time.now.beginning_of_week
          @end_time = Time.now.end_of_week

        when :last_week
          @cache = DailyCache.last_week
          @start_time = (Time.now - 1.week).beginning_of_week
          @end_time = (Time.now - 1.week).end_of_week

        when :month
          @cache = DailyCache.this_month
          @start_time = Time.now.beginning_of_month
          @end_time = Time.now.end_of_month

        when :last_month
          @cache = DailyCache.last_month
          @start_time = (Time.now - 2.months).beginning_of_month
          @end_time = (Time.now - 2.months).end_of_month

        when :quarter
          @cache = DailyCache.this_quarter
          @start_time = Time.now.beginning_of_quarter
          @end_time = Time.now.end_of_quarter

        when :year
          @cache = DailyCache.this_year
          @start_time = Time.now.beginning_of_year
          @end_time = Time.now.end_of_year

        else
          @cache = Cache.today
          @start_time = Time.now.beginning_of_day
          @end_time = Time.now.end_of_day
        end

      end
    
  end
  
end