module RedmineWeekOverride
  module QueryPatch
    def build_from_params(params, defaults = {})
      fields    = params[:fields]    || params[:f]
      operators = params[:operators] || params[:op]

      if fields&.include?('due_date') && (op = operators['due_date'])
        today      = User.current.today
        sow        = Setting.start_of_week.to_i % 7
        offset     = (today.wday - sow) % 7
        start_date = today - offset
        end_date   = start_date + 6

        if op == 'w'
          # Chuyển operator sang between để core dùng giá trị v[]
          operators['due_date'] = '><'
          params[:values] ||= {}
          params[:values]['due_date'] = [start_date.to_s, end_date.to_s]
        elsif op == 'nw'
          operators['due_date'] = '><'
          sd = start_date + 7
          ed = sd + 6
          params[:values] ||= {}
          params[:values]['due_date'] = [sd.to_s, ed.to_s]
          # … tương tự với 'lw', 'l2w' nếu cần
        end
      end

      super(params, defaults)
    end
  end
end

Query.prepend RedmineWeekOverride::QueryPatch
