describe('WalkontableTable', function () {
  var $table
    , $container
    , $wrapper
    , debug = false;

  beforeEach(function () {
    $wrapper = $('<div></div>').css({'overflow': 'hidden', 'position': 'relative'});
    $wrapper.width(100).height(201);
    $container = $('<div></div>');
    $table = $('<table></table>'); //create a table that is not attached to document
    $wrapper.append($container);
    $container.append($table);
    $wrapper.appendTo('body');
    createDataArray();
  });

  afterEach(function () {
    if (!debug) {
      $('.wtHolder').remove();
    }

    $wrapper.remove();
  });

  it("should create as many rows as fits in height", function () {
    var wt = new Walkontable({
      table: $table[0],
      data: getData,
      totalRows: getTotalRows,
      totalColumns: getTotalColumns
    });
    wt.draw();
    expect($table.find('tbody tr').length).toBe(9);
  });

  it("should create as many rows as in `totalRows` if it is smaller than `height`", function () {
    this.data.splice(5, this.data.length - 5);

    var wt = new Walkontable({
      table: $table[0],
      data: getData,
      totalRows: getTotalRows,
      totalColumns: getTotalColumns
    });
    wt.draw();
    expect($table.find('tbody tr').length).toBe(5);
  });

  it("first row should have as many columns as in THEAD", function () {
    var wt = new Walkontable({
      table: $table[0],
      data: getData,
      totalRows: getTotalRows,
      totalColumns: getTotalColumns,
      columnHeaders: [function (col, TH) {
        TH.innerHTML = col + 1;
      }]
    });
    wt.draw();
    expect($table.find('tbody tr:first td').length).toBe($table.find('thead th').length);
  });

  it("should put a blank cell in the corner if both rowHeaders and colHeaders are set", function () {
    var wt = new Walkontable({
      table: $table[0],
      data: getData,
      totalRows: getTotalRows,
      totalColumns: getTotalColumns,
      columnHeaders: [function (col, TH) {
        if( col > - 1) {
          TH.innerHTML = 'Column';
        }
      }],
      rowHeaders: [function (row, TH) {
        if (row > -1) {
          TH.innerHTML = 'Row';
        }
      }]
    });
    wt.draw();
    expect($table.find('thead tr:first th').length).toBe(wt.wtTable.getRenderedColumnsCount() + 1); //4 columns in THEAD + 1 empty cell in the corner
    expect($table.find('thead tr:first th:eq(0)')[0].innerHTML.replace(/&nbsp;/, '')).toBe(''); //corner row is empty (or contains only &nbsp;)
    expect($table.find('thead tr:first th:eq(1)')[0].innerHTML).toBe('Column');
    expect($table.find('tbody tr:first th:eq(0)')[0].innerHTML).toBe('Row');
  });

  it("getCell should only return cells from rendered rows", function () {
    var wt = new Walkontable({
      table: $table[0],
      data: getData,
      totalRows: getTotalRows,
      totalColumns: getTotalColumns
    });
    wt.draw();

    expect(wt.wtTable.getCell(new WalkontableCellCoords(7, 0)) instanceof HTMLElement).toBe(true);
    expect($table.find('tr:eq(8) td:first-child').text()).toEqual(this.data[8][0].toString());
    expect(wt.wtTable.getCell(new WalkontableCellCoords(20, 0))).toBe(-2); //exit code
    expect(wt.wtTable.getCell(new WalkontableCellCoords(25, 0))).toBe(-2); //exit code
  });

  it("getCoords should return coords of TD", function () {
    var wt = new Walkontable({
      table: $table[0],
      data: getData,
      totalRows: getTotalRows,
      totalColumns: getTotalColumns
    });
    wt.draw();

    var $td2 = $table.find('tbody tr:eq(1) td:eq(1)');
    expect(wt.wtTable.getCoords($td2[0])).toEqual(new WalkontableCellCoords(1, 1));
  });

  it("getCoords should return coords of TD (with row header)", function () {

    $wrapper.width(300);

    function plusOne(i) {
      return i + 1;
    }

    var wt = new Walkontable({
      table: $table[0],
      data: getData,
      totalRows: getTotalRows,
      totalColumns: getTotalColumns,
      rowHeaders: [function (row, TH) {
        TH.innerHTML = plusOne(row);
      }]
    });
    wt.draw();

    var $td2 = $table.find('tbody tr:eq(1) td:eq(1)');
    expect(wt.wtTable.getCoords($td2[0])).toEqual(new WalkontableCellCoords(1, 1));
  });

  it("getStretchedColumnWidth should return valid column width when stretchH is set as 'all'", function () {
    var wt = new Walkontable({
      table: $table[0],
      data: getData,
      totalRows: getTotalRows,
      totalColumns: getTotalColumns,
      rowHeaders: [function (row, TH) {
        TH.innerHTML = row + 1;
      }],
      stretchH: 'all'
    });
    wt.draw();
    wt.wtViewport.columnsRenderCalculator.refreshStretching(502);

    expect(wt.wtTable.getStretchedColumnWidth(0, 50)).toBe(125);
    expect(wt.wtTable.getStretchedColumnWidth(1, 50)).toBe(125);
    expect(wt.wtTable.getStretchedColumnWidth(2, 50)).toBe(125);
    expect(wt.wtTable.getStretchedColumnWidth(3, 50)).toBe(127);
  });

  it("getStretchedColumnWidth should return valid column width when stretchH is set as 'last'", function () {
    var wt = new Walkontable({
      table: $table[0],
      data: getData,
      totalRows: getTotalRows,
      totalColumns: getTotalColumns,
      rowHeaders: [function (row, TH) {
        TH.innerHTML = row + 1;
      }],
      stretchH: 'last'
    });
    wt.draw();
    wt.wtViewport.columnsRenderCalculator.refreshStretching(502);

    expect(wt.wtTable.getStretchedColumnWidth(0, 50)).toBe(50);
    expect(wt.wtTable.getStretchedColumnWidth(1, 50)).toBe(50);
    expect(wt.wtTable.getStretchedColumnWidth(2, 50)).toBe(50);
    expect(wt.wtTable.getStretchedColumnWidth(3, 50)).toBe(352);
  });

  it("should use custom cell renderer if provided", function () {
    var wt = new Walkontable({
      table: $table[0],
      data: getData,
      totalRows: getTotalRows,
      totalColumns: getTotalColumns,
      cellRenderer: function (row, column, TD) {
        var cellData = getData(row, column);
        if (cellData !== void 0) {
          TD.innerHTML = cellData;
        }
        else {
          TD.innerHTML = '';
        }
        TD.className = '';
        TD.style.backgroundColor = 'yellow';
      }
    });
    wt.draw();
    expect($table.find('td:first')[0].style.backgroundColor).toBe('yellow');
  });

  it("should remove rows if they were removed in data source", function () {
    this.data.splice(8, this.data.length - 8); //second param is required by IE8

    var wt = new Walkontable({
      table: $table[0],
      data: getData,
      totalRows: getTotalRows,
      totalColumns: getTotalColumns
    });
    wt.draw();
    expect($table.find('tbody tr').length).toBe(8);

    this.data.splice(7, this.data.length - 7); //second param is required by IE8
    wt.draw();
    expect($table.find('tbody tr').length).toBe(7);
  });

  it("should render as much columns as the container width allows, if width is null", function () {
    var wt = new Walkontable({
      table: $table[0],
      data: getData,
      totalRows: getTotalRows,
      totalColumns: getTotalColumns,
      columnHeaders: [function (col, TH) {
        TH.innerHTML = col + 1;
      }]
    });
    wt.draw();
    expect($table.find('thead tr:first').children().length).toBe(2);
    expect($table.find('tbody tr:first').children().length).toBe(2);

    $wrapper.width(200);
    wt.draw();
    expect($table.find('thead tr:first').children().length).toBe(4);
    expect($table.find('tbody tr:first').children().length).toBe(4);
  });

  it("should render as much columns as the container width allows, if width is null (with row header)", function () {
    var wt = new Walkontable({
      table: $table[0],
      data: getData,
      totalRows: getTotalRows,
      totalColumns: getTotalColumns,
      rowHeaders: [function (row, TH) {
        TH.innerHTML = row + 1;
      }],
      columnHeaders: [function (col, TH) {
        TH.innerHTML = col + 1;
      }]
    });
    wt.draw();
    expect($table.find('thead tr:first').children().length).toBe(2);
    expect($table.find('tbody tr:first').children().length).toBe(2);

    $wrapper.width(200);
    wt.draw();
    expect($table.find('thead tr:first').children().length).toBe(4);
    expect($table.find('tbody tr:first').children().length).toBe(4);
  });

  it("should use column width function to get column width", function () {

    $wrapper.width(600);

    var wt = new Walkontable({
      table: $table[0],
      data: getData,
      totalRows: getTotalRows,
      totalColumns: getTotalColumns,
      rowHeaders: [function (row, TH) {
        TH.innerHTML = row + 1;
      }],
      columnHeaders: [function (col, TH) {
        TH.innerHTML = col + 1;
      }],
      columnWidth: function (column) {
        return (column + 1) * 50
      }
    });
    wt.draw();
    expect($table.find('tbody tr:first td:eq(0)').outerWidth()).toBe(50);
    expect($table.find('tbody tr:first td:eq(1)').outerWidth()).toBe(100);
    expect($table.find('tbody tr:first td:eq(2)').outerWidth()).toBe(150);
    expect($table.find('tbody tr:first td:eq(3)').outerWidth()).toBe(200);
  });

  it("should use column width array to get column width", function () {

    $wrapper.width(600);

    var wt = new Walkontable({
      table: $table[0],
      data: getData,
      totalRows: getTotalRows,
      totalColumns: getTotalColumns,
      rowHeaders: [function (row, TH) {
        TH.innerHTML = row + 1;
      }],
      columnHeaders: [function (col, TH) {
        TH.innerHTML = col + 1;
      }],
      columnWidth: [50, 100, 150, 201]
    });
    wt.draw();
    expect($table.find('tbody tr:first td:eq(0)').outerWidth()).toBe(50);
    expect($table.find('tbody tr:first td:eq(1)').outerWidth()).toBe(100);
    expect($table.find('tbody tr:first td:eq(2)').outerWidth()).toBe(150);
    expect($table.find('tbody tr:first td:eq(3)').outerWidth()).toBe(201);
  });

  it("should use column width integer to get column width", function () {

    $wrapper.width(600);

    var wt = new Walkontable({
      table: $table[0],
      data: getData,
      totalRows: getTotalRows,
      totalColumns: getTotalColumns,
      rowHeaders: [function (row, TH) {
        TH.innerHTML = row + 1;
      }],
      columnHeaders: [function (col, TH) {
        TH.innerHTML = col + 1;
      }],
      columnWidth: 100
    });
    wt.draw();
    expect($table.find('tbody tr:first td:eq(0)').outerWidth()).toBe(100);
    expect($table.find('tbody tr:first td:eq(1)').outerWidth()).toBe(100);
    expect($table.find('tbody tr:first td:eq(2)').outerWidth()).toBe(100);
    expect($table.find('tbody tr:first td:eq(3)').outerWidth()).toBe(100);
  });

  it("should use column width also when there are no rows", function () {
    this.data.length = 0;

    $wrapper.width(600);

    var wt = new Walkontable({
      table: $table[0],
      data: getData,
      totalRows: getTotalRows,
      totalColumns: 4,
      rowHeaders: [function (row, TH) {
        TH.innerHTML = row + 1;
      }],
      columnHeaders: [function (col, TH) {
        TH.innerHTML = col + 1;
      }],
      columnWidth: 100
    });
    wt.draw();
    //start from eq(1) because eq(0) is corner header
    expect($table.find('thead tr:first th:eq(1)').outerWidth()).toBe(100);
    expect($table.find('thead tr:first th:eq(2)').outerWidth()).toBe(100);
    expect($table.find('thead tr:first th:eq(3)').outerWidth()).toBe(100);
    expect($table.find('thead tr:first th:eq(4)').outerWidth()).toBe(100);
  });

  it("should render a cell that is outside of the viewport horizontally", function () {
    var wt = new Walkontable({
      table: $table[0],
      data: getData,
      totalRows: getTotalRows,
      totalColumns: getTotalColumns
    });
    wt.draw();
    $table.find('tbody td').html('');
    wt.draw();
    expect($table.find('tbody tr:first td').length).toBe(2);
  });

  it("should not render a cell when fastDraw == true", function () {
    var count = 0
      , wt = new Walkontable({
        table: $table[0],
        data: getData,
        totalRows: getTotalRows,
        totalColumns: getTotalColumns,
        cellRenderer: function (row, column, TD) {
          count++;
          return wt.wtSettings.defaults.cellRenderer(row, column, TD);
        }
      });
    wt.draw();
    var oldCount = count;
    wt.draw(true);
    expect(count).toBe(oldCount);
  });

  it("should not ignore fastDraw == true when grid was scrolled by amount of rows that doesn't exceed endRow", function () {
    var count = 0
      , wt = new Walkontable({
        table: $table[0],
        data: getData,
        totalRows: getTotalRows,
        totalColumns: getTotalColumns,
        cellRenderer: function (row, column, TD) {
          count++;
          return wt.wtSettings.defaults.cellRenderer(row, column, TD);
        },
        viewportRowCalculatorOverride: function(calc) {
          calc.endRow += 10;
        }
      });
    wt.draw();
    var oldCount = count;

    wt.scrollVertical(8);
    wt.draw(true);
    expect(count).not.toBeGreaterThan(oldCount);
  });

  it("should ignore fastDraw == true when grid was scrolled by amount of rows that exceeds endRow", function () {
    var count = 0
      , wt = new Walkontable({
        table: $table[0],
        data: getData,
        totalRows: getTotalRows,
        totalColumns: getTotalColumns,
        cellRenderer: function (row, column, TD) {
          count++;
          return wt.wtSettings.defaults.cellRenderer(row, column, TD);
        },
        viewportRowCalculatorOverride: function(calc) {
          calc.endRow += 10;
        }
      });
    wt.draw();
    var oldCount = count;

    wt.scrollVertical(10);
    wt.draw(true);
    expect(count).not.toBeGreaterThan(oldCount);

    wt.scrollVertical(11);
    wt.draw(true);
    expect(count).toBeGreaterThan(oldCount);
  });

  it("should not ignore fastDraw == true when grid was scrolled by amount of columns that doesn't exceed endColumn", function () {
    createDataArray(50, 50);
    var count = 0
      , wt = new Walkontable({
        table: $table[0],
        data: getData,
        totalRows: getTotalRows,
        totalColumns: getTotalColumns,
        cellRenderer: function (row, column, TD) {
          count++;
          return wt.wtSettings.defaults.cellRenderer(row, column, TD);
        },
        viewportColumnCalculatorOverride: function(calc) {
          calc.endColumn += 10;
        }
      });
    wt.draw();
    var oldCount = count;

    wt.scrollHorizontal(8);
    wt.draw(true);

    expect(count).not.toBeGreaterThan(oldCount);
  });

  it("should ignore fastDraw == true when grid was scrolled by amount of columns that exceeds endColumn", function () {
    createDataArray(50, 50);
    var count = 0
      , wt = new Walkontable({
        table: $table[0],
        data: getData,
        totalRows: getTotalRows,
        totalColumns: getTotalColumns,
        cellRenderer: function (row, column, TD) {
          count++;
          return wt.wtSettings.defaults.cellRenderer(row, column, TD);
        },
        viewportColumnCalculatorOverride: function(calc) {
          calc.endColumn += 10;
        }
      });
    wt.draw();
    var oldCount = count;

    wt.scrollHorizontal(10);
    wt.draw(true);
    expect(count).not.toBeGreaterThan(oldCount);

    wt.scrollHorizontal(11);
    wt.draw(true);
    expect(count).toBeGreaterThan(oldCount);
  });

  describe('cell header border', function () {
    it("should be correct visible in fixedColumns and without row header", function () {
      createDataArray(50, 50);
      $wrapper.width(500).height(400);

      var count = 0,
        wt = new Walkontable({
          table: $table[0],
          data: getData,
          totalRows: getTotalRows,
          totalColumns: getTotalColumns,
          columnWidth: 70,
          fixedColumnsLeft: 2,
          columnHeaders: [function (col, TH) {}]
        });
      wt.draw();

      expect($('.ht_clone_top_left_corner thead tr th').eq(0).css('border-left-width')).toBe('1px');
      expect($('.ht_clone_top_left_corner thead tr th').eq(0).css('border-right-width')).toBe('1px');
      expect($('.ht_clone_top_left_corner thead tr th').eq(1).css('border-left-width')).toBe('0px');
      expect($('.ht_clone_top_left_corner thead tr th').eq(1).css('border-right-width')).toBe('1px');
    });
  });


  describe('isLastRowFullyVisible', function () {
    it('should be false because it is only partially visible', function () {
      createDataArray(8, 4);

      $wrapper.width(185).height(175);

      var wt = new Walkontable({
        table: $table[0],
        data: getData,
        totalRows: getTotalRows,
        totalColumns: getTotalColumns
      });
      wt.draw();

      expect(wt.wtTable.isLastRowFullyVisible()).toEqual(false);
    });

    it('should be true because it is fully visible', function () {
      createDataArray(8, 4);

      $wrapper.width(185).height(185);

      var wt = new Walkontable({
        table: $table[0],
        data: getData,
        totalRows: getTotalRows,
        totalColumns: getTotalColumns
      });
      wt.draw();
      wt.scrollVertical(7);
      wt.draw();

      expect(wt.wtTable.isLastRowFullyVisible()).toEqual(true);
    });
  });

  xdescribe('isLastColumnFullyVisible', function () {
    it('should be false because it is only partially visible', function () {
      createDataArray(18, 4);

      $wrapper.width(209).height(185);

      var wt = new Walkontable({
        table: $table[0],
        data: getData,
        totalRows: getTotalRows,
        totalColumns: getTotalColumns
      });
      wt.draw();

      expect(wt.wtTable.isLastColumnFullyVisible()).toEqual(false); //few pixels are obstacled by scrollbar
    });

    it('should be true because it is fully visible', function () {
      createDataArray(18, 4);

      $wrapper.width(180).height(185);

      var wt = new Walkontable({
        table: $table[0],
        data: getData,
        totalRows: getTotalRows,
        totalColumns: getTotalColumns
      });
      wt.draw();
      wt.scrollHorizontal(1);

      expect(wt.wtTable.isLastColumnFullyVisible()).toEqual(true);
    });
  });
});
