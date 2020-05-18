// IntanceTypes / Images mustach rendering
(function(){
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
        console.log(dsList);
        $('#dataset-list-ul').html(dsList);
      } else {
        $('#dataset-list-ul').html($('<li>None</li>'));
      }
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
        var type = currentGroup.images[i].spec.type;
        currentGroup.images[i].typeLabel = typeTextList[type];
      }

      $itContainer.html(Mustache.render(itTemplate, currentGroup.instanceTypes));
      $imageContainer.html(Mustache.render(imageTemplate, currentGroup.images));
      $('[data-toggle="tooltip"]').tooltip();
      $('input:radio[name="instance_type"]:first').trigger('click');
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
      cpuOnly = itData.spec['limits.nvidia.com/gpu'] <= 0;
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
    });

    $imageContainer.off('click.images');
    $imageContainer.on('click.images', 'input:radio[name="image"]', function(event){
      $('div[role="image-not-match-gpu-instance"]').toggleClass('hide', true);
      $currentIt = $('input:radio[name="instance_type"]:checked');
      itData = currentGroup.instanceTypes[itIndex];
      itHasGpu = itData.spec['limits.nvidia.com/gpu'] > 0;
      $image = $(event.target);
      imageIndex = +$image.data('index');
      imageData = currentGroup.images[imageIndex];
      if (itHasGpu && imageData.spec && imageData.spec.type === 'cpu') {
        $('div[role="image-not-match-gpu-instance"]').toggleClass('hide', false);
      }
    });

    var $groupSelect = $('select[name="group"]');
    var reloadPage = function() {
      location.href = '/hub/spawn';
    };
    $groupSelect.change(function() {
      var that = this;
      updatePrimehubContext()
        .done(function(){
          window.currentGroup = getCurrentGroup(that.value);
          updateUsagesDashboard(currentGroup);
          updateSpawnerOptions(currentGroup);
        })
        .fail(reloadPage);
    });
    // init
    $groupSelect.val( $groupSelect.find('option').first().val() ).trigger("change");
    window.updateContextIntervalId = window.setInterval(function(){
      if (window.currentGroup) {
        updatePrimehubContext()
          .done(function(){
            window.currentGroup = getCurrentGroup(window.currentGroup.name);
            updateUsagesDashboard(window.currentGroup);
          })
          .fail(reloadPage);
      }
    }, updateInterval);
  } else {
    $('#spawn_form input[type=submit]').hide()
  }
})();
