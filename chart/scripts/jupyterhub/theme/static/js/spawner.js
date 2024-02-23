// IntanceTypes / Images mustach rendering
(function(){
  // Precondition. The javascript should be only run in iframe.
  if (window.top === window.self) {
    return;
  }

  // If user can not spawn anything hide start btn.
  var canSpawn = $('#you-can-not-pass').length === 0;
  var alphabetCompare = function(current, next) {
    if (current.toLowerCase() < next.toLowerCase()) {
      return -1;
    } else {
      return 1;
    }
  };

  var alphabetSort = function(current, next){
    return alphabetCompare(current.displayName, next.displayName);
  };

  if (canSpawn) {
    window.currentGroup = null;
    const updateInterval = 6400;
    var userLimitsTemplate = $('#user-limits-template').html();
    var groupUsageTemplate = $('#group-usage-template').html();
    var itTemplate = $('#it-template').html();
    var imageTemplate = $('#image-template').html();
    var $userLimitsContainer = $('#user-limits-body');
    var $groupUsageContainer = $('#group-usage-body');
    var $itContainer = $('#it-container');
    var $imageContainer = $('#image-container');
    var $groupCpuLimit = $('#group-cpu-limit');
    var $groupMemLimit = $('#group-mem-limit');
    var $groupGpuLimit = $('#group-gpu-limit');
    var $groupCpuUsage = $('#group-cpu-usage');
    var $groupMemUsage = $('#group-mem-usage');
    var $groupGpuUsage = $('#group-gpu-usage');

    // Pre parse the templates
    Mustache.parse(userLimitsTemplate);
    Mustache.parse(groupUsageTemplate);
    Mustache.parse(itTemplate);
    Mustache.parse(imageTemplate);

    var getActiveGroup = function() {
      // parse the top window path.
      // For example, '/console/g/phusers/hub' should be matched with the first group 'phusers'
      var regex = /\/g\/([^/]*)\/hub$/;
      var m = regex.exec(window.top.location.pathname);
      if (m) {
        return m[1];
      }
    }

    var checkInstanceTypesQuota = function(currentGroup) {
      // parse the top window path.
      var quota = {
        'cpu': $.isNumeric(currentGroup.quotaCpu) && parseFloat(currentGroup.quotaCpu),
        'memory': $.isNumeric(currentGroup.quotaMemory) && parseFloat(currentGroup.quotaMemory),
        'gpu': $.isNumeric(currentGroup.quotaGpu) && parseInt(currentGroup.quotaGpu),
      }
      for (var i = 0; i < currentGroup.instanceTypes.length; i++) {
        itData = currentGroup.instanceTypes[i];
        $itRadio = $('#instance_type-item-' + i);
        $itLabel = $itRadio.parents('label');

        $itLabel.removeClass('disabled');
        $itRadio.removeAttr('disabled');
        var itQuota = {
          'cpu': itData.spec['limits.cpu'],
          'memory': parseFloat(itData.spec['limits.memory'].slice(0, -1)),
          'gpu': 'limits.nvidia.com/gpu' in itData.spec && itData.spec['limits.nvidia.com/gpu'],
        }
        var disabled = Object.keys(quota).reduce((h, k) => {
          return (quota[k] !== false && itQuota[k] !== false && quota[k] < itQuota[k]) || h;
        }, false);
        if (disabled) {
          $itLabel.addClass('disabled');
          $itRadio.attr('disabled', 'disabled');
        }
      }
    }

    var updatePrimehubContext = function() {
      var url = window.groupFetchUri || '/hub/api/primehub/groups';
      var dfd = $.Deferred();
      $.get(url)
        .done(function(data) {
          if (data['error']) {
            dfd.reject(data);
          } else {
            PrimeHubContext = data;
            dfd.resolve();
          }
        })
        .fail(function(data) {
          dfd.reject(data);
        })
      return dfd.promise();
    };

    var updateUsagesDashboard = function(currentGroup) {
      groupCpuLimit = currentGroup.projectQuotaCpu != null ? currentGroup.projectQuotaCpu : "∞"
      groupMemLimit = currentGroup.projectQuotaMemory != null ? currentGroup.projectQuotaMemory + "GB" : "∞"
      groupGpuLimit = currentGroup.projectQuotaGpu != null ? currentGroup.projectQuotaGpu : "∞"
      groupUsageData = {
        'cpuUsage': currentGroup.usage.cpu,
        'cpuLimit': groupCpuLimit,
        'memUsage': currentGroup.usage.memory,
        'memLimit': groupMemLimit,
        'gpuUsage': currentGroup.usage.gpu,
        'gpuLimit': groupGpuLimit
      };

      $groupUsageContainer.html(Mustache.render(groupUsageTemplate, groupUsageData));
      $userLimitsContainer.html(Mustache.render(userLimitsTemplate, currentGroup));

      // datasets
      if (currentGroup.datasets.length >= 1) {
        dsList = [];
        currentGroup.datasets.forEach(function(dataset){
          $liTemplate = $('<li></li>');
          $liTemplate.html(dataset.displayName);
          dsList.push($liTemplate);
        });
        $('#volume-list-ul').html(dsList);
      } else {
        $('#volume-list-ul').html($('<li>None</li>'));
      }

      for (var i = 0; i < currentGroup.instanceTypes.length; i++) {
        spec = currentGroup.instanceTypes[i].spec;
        var resourceLimits = ["CPU: ", spec['limits.cpu'], " / Memory: ", spec['limits.memory'], " / GPU: ", spec['limits.nvidia.com/gpu']].join('');
        $itInfo = $('#instance_type-item-info-icon-' + i);
        $itInfo.attr('title', resourceLimits);
      }
      checkInstanceTypesQuota(currentGroup);
    };

    var updateSpawnerOptions = function(currentGroup) {
      var typeTextList = {
        'both': 'Universal',
        'cpu': 'CPU',
        'gpu': 'GPU'
      };

      // add index for mustache
      for (var i = 0; i < currentGroup.instanceTypes.length; i++) {
        spec = currentGroup.instanceTypes[i].spec;
        currentGroup.instanceTypes[i].index = i;
        currentGroup.instanceTypes[i].resourceLimits = ["CPU: ", spec['limits.cpu'], " / Memory: ", spec['limits.memory'], " / GPU: ", spec['limits.nvidia.com/gpu']].join('');
      }

      for (var i = 0; i < currentGroup.images.length; i++) {
        currentGroup.images[i].index = i;
        var spec = currentGroup.images[i].spec;
        var isGroupImage = spec.groupName && spec.groupName.length > 0;
        var label = (currentGroup.images[i].isReady ? '' : '(Not Ready) ') + (isGroupImage ? 'Group' : 'System') + ' / ' + typeTextList[spec.type];
        currentGroup.images[i].typeLabel = label;
      }

      $itContainer.html(Mustache.render(itTemplate, currentGroup.instanceTypes));
      $imageContainer.html(Mustache.render(imageTemplate, currentGroup.images));

      checkInstanceTypesQuota(currentGroup);

      $('[data-toggle="tooltip"]').tooltip();
      $('input:radio[name="instance_type"][disabled!="disabled"]:first').trigger('click');
      $('input:radio[name="image"][disabled!="disabled"]:first').trigger('click');

      $('#spawn_form input[type=submit]').on('click', function(evt) {
        evt.preventDefault();
        $this = $(evt.currentTarget);
        $this.addClass('disabled');
        $this.attr('disabled', 'disabled');
        $('#spawner-mask').addClass('active');
        window.clearInterval(window.updateContextIntervalId); // Stop request group usage info.
        $('#spawn_form').submit();
      });

      // select instance type from query string
      instance_type_index = currentGroup.instanceTypes.findIndex((instanceTypes)=>instanceTypes.name==SpawnOptions.default_instance_type)
      if ($('#instance_type-item-' + instance_type_index).attr('disabled') == 'disabled') {
        instance_type_index = -1;
      }
      if (instance_type_index != -1) {
        $('input:radio[name="instance_type"][value="' + SpawnOptions.default_instance_type +'"]').trigger('click');
      } else if (SpawnOptions.default_instance_type) {
        $('#instance-type-warn').show();
        $('#instance-type-warn-text').text('Instance type "' + SpawnOptions.default_instance_type + '" is not available. A default instance type is selected for you.');
      }

      // select image from query string, must be after selecting intance type because of CPU/GPU will change the availability
      image_index = currentGroup.images.findIndex((image)=>image.name==SpawnOptions.default_image)
      if ($('#image-item-' + image_index).attr('disabled') == 'disabled') {
        image_index = -1;
      }
      if (image_index != -1) {
        $('input:radio[name="image"][value="' + SpawnOptions.default_image +'"]').trigger('click');
      } else if (SpawnOptions.default_image) {
        $('#image-warn').show();
        $('#image-warn-text').text('Image "' + SpawnOptions.default_image + '" is not available. A default image is selected for you.');
      }

      // pop-up for autolaunch
      if (instance_type_index != -1 && image_index != -1 && SpawnOptions.autolaunch == 1) {
        $('#dialog-instance-type').text(['Instance Type: ', currentGroup.instanceTypes[instance_type_index].displayName, ' (', currentGroup.instanceTypes[instance_type_index].resourceLimits, ')'].join(''));
        $('#dialog-image').text('Image: ' + currentGroup.images[image_index].displayName);
        $('#comfirm_dialog').modal();
      }
    };

    var getCurrentGroup = function(name) {
      group = $.grep(PrimeHubContext.groups, function(group) {
        return group.name === name;
      })[0];
      group.instanceTypes.sort(alphabetSort);
      group.images.sort(alphabetSort);
      // Transfer number to string for disply zero quota.
      group.quotaCpu = $.isNumeric(group.quotaCpu) && "" + group.quotaCpu;
      group.quotaGpu = $.isNumeric(group.quotaGpu) && "" + group.quotaGpu;
      group.quotaMemory = $.isNumeric(group.quotaMemory) && "" + group.quotaMemory;
      return group;
    };

    // Event bind
    $itContainer.off('click.instanceTypes');
    $itContainer.on('click.instanceTypes', 'input:radio[name="instance_type"]', function(event){
      $it = $(event.target);
      itIndex = +$it.data('index');
      itData = currentGroup.instanceTypes[itIndex];
      cpuOnly = 'limits.nvidia.com/gpu' in itData.spec && itData.spec['limits.nvidia.com/gpu'] <= 0;
      $images = $('label.image-option');
      $images.removeClass('disabled');
      $images.find('input[type="radio"]').removeAttr('disabled');
      if (cpuOnly) {
        $gpuImages = $('label.image-option[data-image-type="gpu"]');
        $gpuImages.addClass('disabled');
        $gpuImages.find('input[type="radio"]').attr('disabled', 'disabled');
      }
      if ($images.find(':checked').prop('disabled')) {
        $('input:radio[name="image"][disabled!="disabled"]:first').trigger('click');
      } else {
        $images.find(':checked').trigger('click');
      }
      $notReadyImages = $('label.image-option[data-is-ready="false"]');
      $notReadyImages.addClass('disabled');
      $notReadyImages.find('input[type="radio"]').attr('disabled', 'disabled');
      $('input[name="instance_type_display_name"]:hidden')
        .val($(this)
        .data('display-name'));
    });

    $imageContainer.off('click.images');
    $imageContainer.on('click.images', 'input:radio[name="image"]', function(event){
      $('div[role="image-not-match-gpu-instance"]').toggleClass('hide', true);
      $currentIt = $('input:radio[name="instance_type"]:checked');
      itData = currentGroup.instanceTypes[itIndex];
      itHasGpu = 'limits.nvidia.com/gpu' in itData.spec && itData.spec['limits.nvidia.com/gpu'] > 0;
      $image = $(event.target);
      imageIndex = +$image.data('index');
      imageData = currentGroup.images[imageIndex];
      if (itHasGpu && imageData.spec && imageData.spec.type === 'cpu') {
        $('div[role="image-not-match-gpu-instance"]').toggleClass('hide', false);
      }

      $('input[name="image_display_name"]:hidden')
        .val($(this)
        .data('image-name'));
    });
    var reloadPage = function() {
      location.href = '/hub/spawn';
    };

    $("#diaglog_start").click(function() {
      $('#spawn_form input[type=submit]').trigger("click");
    })

    var activeGroup = getActiveGroup();
    if (!activeGroup) {
      window.top.location.reload();
      return;
    }
    $('input[name="group"]').val(activeGroup);

    updatePrimehubContext()
      .done(function(){
        window.currentGroup = getCurrentGroup(activeGroup);
        updateUsagesDashboard(currentGroup);
        updateSpawnerOptions(currentGroup);
        loadLastEnvVars(PrimeHubContext.predefinedEnvs);
      })
      .fail(reloadPage);

    window.updateContextIntervalId = window.setInterval(function(){
      if (window.currentGroup) {
        updatePrimehubContext()
          .done(function(){
            window.currentGroup = getCurrentGroup(activeGroup);
            updateUsagesDashboard(window.currentGroup);
          })
          .fail(reloadPage);
      }
    }, updateInterval);
  } else {
    $('#spawn_form input[type=submit]').hide()
  }
})();
