# plugins/redmine_week_override/lib/redmine_week_override/query_patch.rb
module RedmineWeekOverride
  module QueryPatch
    # Ghi đè build_from_params, giữ signature gốc
    def build_from_params(params, defaults = {})
      fields    = params[:fields]    || params[:f]
      operators = params[:operators] || params[:op]

      if fields&.include?('due_date') && (orig_op = operators['due_date'])
        today      = User.current.today
        # Chuyển start_of_week (1=Mon…7=Sun) về wday (0=Sun…6=Sat)
        sow        = Setting.start_of_week.to_i % 7
        offset     = (today.wday - sow) % 7
        base_start = today - offset

        # Xác định start_date và end_date cho từng operator
        sd, ed = case orig_op
                 when 'w'   # This week
                   [ base_start,        base_start + 6 ]
                 when 'nw'  # Next week
                   [ base_start + 7,    base_start + 13 ]
                 when 'lw'  # Last week
                   [ base_start - 7,    base_start - 1 ]
                 when 'l2w' # Last two weeks
                   [ base_start - 14,   base_start - 1 ]
                 else
                   [ nil, nil ]
                 end

        if sd && ed
          # Ép operator thành between để core dùng values
          operators['due_date'] = '><'

          # Lấy trước toàn bộ params[:values] hoặc params[:v] ban đầu,
          # chuyển thành Hash thật (to_h / to_unsafe_h), rồi wrap thành indifferent_access
          raw = if params[:values].respond_to?(:to_unsafe_h)
                  params[:values].to_unsafe_h
                elsif params[:v].respond_to?(:to_unsafe_h)
                  params[:v].to_unsafe_h
                else
                  {}
                end
          merged = raw.with_indifferent_access

          # Chỉ override key due_date, giữ nguyên tất cả keys khác
          merged['due_date'] = [ sd.to_s, ed.to_s ]

          # Gán lại cho cả hai biến core sẽ đọc
          params[:values] = merged
          params[:v]      = merged
        end
      end

      super(params, defaults)
    end
  end
end

# Ghi đè Query
Query.prepend RedmineWeekOverride::QueryPatch
