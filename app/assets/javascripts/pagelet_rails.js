//= require_tree ./views
//= require pagelet_rails/jquery.ajaxprogress

(function (w) {

  var root = w['PageletRails'] || {};
  w['PageletRails'] = root;

  root.addParamsToUrl = function( url, data ) {
    if ( ! $.isEmptyObject(data) ) {
      url += ( url.indexOf('?') >= 0 ? '&' : '?' ) + $.param(data);
    }
    return url;
  };

  root.appendScriptTag = function (text) {
    var script = document.createElement( "script" );
    script.type = "text/javascript";
    script.text = text;
    $("body").append(script);
  };

  root.loadDirectly = function(data) {
    $.ajax({
      url: data.url,
      dataType: 'script',
      headers: {
        'X-Pagelet': 'pagelet'
      }
    }).done(function(_) {
    }).fail(function(){
      var html = JST['views/pagelet_load_failed']({
        pagelet_url: data.url,
        reload_function: "PageletRails.loadPagelets('#" + data.id + "');"
      });
      data.elem.html(html)
    });
  };

  root.loadThroughBatchProxy = function(urls) {
    if (urls.length == 0) { return; }

    var prev_index = 0;

    $.ajax({
      url: '/pagelet_proxy',
      data: {
        urls: urls
      },
      dataType: 'text',
      cache: false,
      headers: {
        'X-Pagelet': 'pagelet'
      },
      progress: function(_, progressEvent) {
        var text = progressEvent.target.responseText;
        var end_index = -1;

        do {
          end_index = text.indexOf("\n\n//\n\n", prev_index);

          if (end_index != -1) {
            var new_text = text.substring(prev_index, end_index);

            eval(new_text);

            prev_index = end_index + 1;
            // console.log('found');
            // console.log(new_text);
          }

        } while (end_index != -1);
      }
    });
  };

  root.loadPagelets = function(selector) {
    selector = selector || '[data-widget-url]';
    var groups = {};

    $(selector).each(function(index, elem) {
      var $el = $(elem);
      var path = $el.data('widget-url');
      var group = $el.data('pagelet-group');
      var id = $el.attr('id');

      var url = root.addParamsToUrl(path, {
        target_container: id,
        original_pagelet_options: $el.data('pagelet-options')
      });

      groups[group] = groups[group] || [];
      groups[group].push({
        id: id,
        elem: $el,
        url: url,
        group: group
      });
    });

    for (var group_name in groups) {
      if (groups.hasOwnProperty(group_name)) {
        var group = groups[group_name];

        if (group.length == 1) {
          root.loadDirectly(group[0]);
        } else {
          var urls = group.map(function(e) { return e.url; });
          root.loadThroughBatchProxy(urls);
        }
      }
    }
  };

  root.pageletArrived = function(id, content) {
    root.placeToContainer(id, content);
    root.processDataRemoteTags();
    $(document).trigger('pagelet-loaded');
  };

  root.placeToContainer = function(id, content) {
    $('#' + id).html(content);
  };

  root.processDataRemoteTags = function() {
    $('form[data-remote]').each(function(index, elem){
      var $el = $(elem);
      var container = $el.closest('[data-pagelet-container]');

      if (!container) {
        return;
      }

      var hidden_field = $el.find('input[name=target_container]')[0];
      if (!hidden_field) {
        $("<input/>", {
          name: "target_container",
          type: "hidden",
          value: container.attr('id')
        }).appendTo($el);
      }

      hidden_field = $el.find('input[name=original_pagelet_options]')[0];
      if (!hidden_field) {
        $("<input/>", {
          name: "original_pagelet_options",
          type: "hidden",
          value: container.data('pagelet-options')
        }).appendTo($el);
      }
    });

    var selector = 'a[data-remote]:not([disabled]),button[data-remote]:not([disabled])';
    $(selector).each(function(index, elem){
      var $el = $(elem);
      var container = $el.closest('[data-pagelet-container]');

      if (!container) {
        return;
      }

      var params = $el.data('params');
      if (!params) {
        var value = $.param({
          target_container: container.attr('id'),
          original_pagelet_options: container.data('pagelet-options')
        });
        $el.data('params', value);
      }
    });
  };

  function initialise() {
    document.addEventListener("turbolinks:load", function(){
      root.loadPagelets();
      root.processDataRemoteTags();
    });
  }

  initialise();
})(window);




