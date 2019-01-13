$(document).on('turbolinks:load', function () {
  const canvases = $('.score-chart');
  canvases.each(function () {
    const canvas = $(this);

    const labels = canvas.data('labels');
    const rawData = canvas.data('datasets');

    const colors = palette('tol-rainbow', rawData.length).map(function(hex) {
      return '#' + hex
    });

    const datasets = rawData.map(function (dataset, i) {
      return {
        label: dataset.label,
        data: dataset.data,
        backgroundColor: colors[i],
        borderColor: colors[i],
        pointRadius: 8,
        pointHoverRadius: 12,
        fill: false
      }
    });

    new Chart(canvas, {
      type: 'line',
      data: {
        labels: labels,
        datasets: datasets
      },
      options: {
        aspectRatio: 1.5,
        tooltips: {
          mode: 'point',
          itemSort: function(a, b) { return b.yLabel - a.yLabel }
        },
        hover: {
          mode: 'point'
        }
      }
    })
  })
});
