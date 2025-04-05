$(document).ready(function() {
  console.log(test)
  $('.share-link-button').on('click', function(e) {
    e.preventDefault();
    var url = $(this).data('share-url');

    if (navigator.clipboard && navigator.clipboard.writeText) {
      navigator.clipboard.writeText(url)
          .then(function() {
            alert('Đã sao chép link chia sẻ vào clipboard: ' + url);
          })
          .catch(function(err) {
            console.error('Clipboard copy failed', err);
            alert('Không thể copy tự động. Bạn hãy copy thủ công: ' + url);
          });
    } else {
      // Fallback nếu trình duyệt không hỗ trợ Clipboard API
      var $tempInput = $('<input>');
      $('body').append($tempInput);
      $tempInput.val(url).select();
      try {
        document.execCommand('copy');
        alert('Đã sao chép link chia sẻ vào clipboard: ' + url);
      } catch (e) {
        alert('Link chia sẻ: ' + url);
      }
      $tempInput.remove();
    }
  });
});
