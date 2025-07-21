// plugins/redmine_refresh_sheet/app/assets/javascripts/refresh_sheet.js
jQuery(function($) {
    $('#refresh-sheet-btn').on('click', function(e) {
        e.preventDefault();
        $('#sheet-refresh-result').text('Đang gửi yêu cầu…');

        $.getJSON('/refresh_sheet/execute', { project_id: gon.project_id })
            .done(function(data) {
                var now = new Date().toLocaleString();
                if (data.success) {
                    $('#sheet-refresh-result').html('[' + now + '] ✅ ' + data.message);
                } else {
                    $('#sheet-refresh-result').html('[' + now + '] ❌ ' + data.error);
                }
            })
            .fail(function(xhr, status, err) {
                $('#sheet-refresh-result')
                    .html('[' + new Date().toLocaleString() + '] ❌ Lỗi: ' + err);
            });
    });
});
