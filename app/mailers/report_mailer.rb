class ReportMailer < ActionMailer::Base

  def daily_report(email, timezone="UTC")
    report = Snorby::Report.build_report('yesterday', timezone)
    attachments["snorby-daily-report.pdf"] = report[:pdf]

    # File.open("/Users/mephux/Desktop/test-#{timezone}.pdf", "wb") do |file|
      # file << report[:pdf]
    # end

    mail(:to => email,
         :from => (Setting.email? ? Setting.find(:email) : "snorby@snorby.org"),
         :subject => "Snorby Daily Report: #{report[:start_time].strftime('%A, %B %d, %Y')}")
  end

  def weekly_report(email, timezone="UTC")
    report = Snorby::Report.build_report('last_week', timezone)
    attachments["snorby-weekly-report.pdf"] = report[:pdf]

    # File.open("/Users/jandre/Desktop/test-#{timezone}.pdf", "wb") do |file|
      # file << report[:pdf]
    # end

    mail(:to => email, 
         :from => (Setting.email? ? Setting.find(:email) : "snorby@snorby.org"), 
         :subject => "Snorby Weekly Report: #{report[:start_time].strftime('%A, %B %d, %Y %I:%M %p')} - #{report[:end_time].strftime('%A, %B %d, %Y %I:%M %p')}")
  end

  def monthly_report(email, timezone="UTC")
    report = Snorby::Report.build_report('last_month', timezone)
    attachments["snorby-monthly-report.pdf"] = report[:pdf]
    mail(:to => email, 
         :from => (Setting.email? ? Setting.find(:email) : "snorby@snorby.org"), 
         :subject => "Snorby Monthly Report: #{report[:start_time].strftime('%A, %B %d, %Y %I:%M %p')} - #{report[:end_time].strftime('%A, %B %d, %Y %I:%M %p')}")
  end

  def update_report(email, data, timezone="UTC")
    @data = data
    total_event_count = data.map(&:event_count).sum
    p @data
    sigs = data.map(&:signature_metrics).compact.map{ |k|  k.keys }.join(', ')
    srcs = data.map(&:src_ips).compact.map{ |k|  k.keys }.join(', ')
    dsts = data.map(&:dst_ips).compact.map{ |k|  k.keys }.join(', ')
    mail(:to => email,
      :from => (Setting.email? ? Setting.find(:email) : "snorby@snorby.org"),
      :body => "Signatures: #{sigs} \nSource IPs: #{srcs} \nDestination IPs: #{dsts} \n\nView:  http://leviathan:3000/ ",
      :subject => "Snorby Event [Count: #{total_event_count}] ")
  end

end
