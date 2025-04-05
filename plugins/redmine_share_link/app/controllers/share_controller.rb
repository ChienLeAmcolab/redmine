# plugins/redmine_share_link/app/controllers/share_controller.rb
class ShareController < ApplicationController
  skip_before_action :check_if_login_required, :authorize, raise: false, only: [:issue, :project]
  # 'raise: false' để tránh lỗi nếu filter không định nghĩa trực tiếp&#8203;:contentReference[oaicite:2]{index=2}

  def issue
    @issue = Issue.find(params[:id]) rescue nil
    unless @issue
      render_404; return
    end

    # Kiểm tra token
    token = params[:token].to_s
    valid_token = SharedHelper.generate_issue_token(@issue)
    if token != valid_token
      # Token không hợp lệ
      if User.current.logged?
        # Nếu đã đăng nhập, chuyển hướng về trang issue gốc
        redirect_to issue_path(@issue)
      else
        # Nếu chưa đăng nhập, yêu cầu đăng nhập rồi trở lại
        redirect_to signin_path(back_url: issue_path(@issue))
      end
      return
    end

    # Token hợp lệ
    if User.current.logged?
      # Nếu người dùng đã đăng nhập và vẫn dùng link chia sẻ, chuyển hướng trực tiếp 
      redirect_to issue_path(@issue) and return
    end

    # Người dùng chưa đăng nhập nhưng token đúng => hiển thị trang chia sẻ công khai
    @project = @issue.project  # đặt project hiện tại để view có ngữ cảnh
    render 'share/issue', layout: 'base'  # dùng layout Redmine chuẩn
  end

  def project
    @project = Project.find_by_identifier(params[:id]) || Project.find_by_id(params[:id]) rescue nil
    unless @project
      render_404; return
    end

    # Kiểm tra token
    token = params[:token].to_s
    valid_token = SharedHelper.generate_project_token(@project)
    if token != valid_token
      if User.current.logged?
        redirect_to project_path(@project)
      else
        redirect_to signin_path(back_url: project_path(@project))
      end
      return
    end

    if User.current.logged?
      redirect_to project_path(@project) and return
    end

    # Với project, nếu token hợp lệ và user chưa login, hiển thị trang chia sẻ
    render 'share/project', layout: 'base'
  end
end
