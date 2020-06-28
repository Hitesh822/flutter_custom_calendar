import 'package:custom_calendar/calendar.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(home: MyApp()));
}

enum CalendarViews{ dates, months, year }

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  DateTime _currentDateTime;
  DateTime _selectedDateTime;
  List<Calendar> _sequentialDates;
  int midYear;
  CalendarViews _currentView = CalendarViews.dates;
  final List<String> _weekDays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
  final List<String> _monthNames = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

  @override
  void initState() {
    super.initState();
    final date = DateTime.now();
    _currentDateTime = DateTime(date.year, date.month);
    _selectedDateTime = DateTime(date.year, date.month, date.day);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() => _getCalendar());
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(20),
          ),
          child: (_currentView == CalendarViews.dates) ? _datesView() 
          : (_currentView == CalendarViews.months) ? _showMonthsList() : _yearsView(midYear ?? _currentDateTime.year)
        ),
      ),
    );
  }

  // dates view
  Widget _datesView(){
    return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // header
              Row(
                children: <Widget>[
                  // prev month button
                  _toggleBtn(false),
                  // month and year
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _currentView = CalendarViews.months),
                      child: Center(
                        child: Text(
                          '${_monthNames[_currentDateTime.month-1]} ${_currentDateTime.year}',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                  // next month button
                  _toggleBtn(true),
                ],
              ),
              SizedBox(height: 20,),
              Divider(color: Colors.white,),
              SizedBox(height: 20,),
              Flexible(child: _calendarBody()),
            ],
          );
  }

  // next / prev month buttons
  Widget _toggleBtn(bool next) {
    return InkWell(
      onTap: (){
        if(_currentView == CalendarViews.dates){
          setState(() => (next) ? _getNextMonth() : _getPrevMonth());
        }
        else if(_currentView == CalendarViews.year){
          if(next){
            midYear = (midYear == null) ? _currentDateTime.year + 9 : midYear + 9;
          }
          else{
            midYear = (midYear == null) ? _currentDateTime.year - 9 : midYear - 9;
          }
          setState(() {});
        }
      },
      child: Container(
        alignment: Alignment.center,
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.5),
              offset: Offset(3, 3),
              blurRadius: 3,
              spreadRadius: 0,
            ),
          ],
          gradient: LinearGradient(
            colors: [Colors.black, Colors.black.withOpacity(0.1)],
            stops: [0.5, 1],
            begin: Alignment.bottomRight,
            end: Alignment.topLeft,
          )
        ),
        child: Icon((next) ? Icons.arrow_forward_ios : Icons.arrow_back_ios, color: Colors.white,),
      ),
    );
  }

  // calendar
  Widget _calendarBody() {
    if(_sequentialDates == null) return Container();
    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: _sequentialDates.length + 7,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        mainAxisSpacing: 20,
        crossAxisCount: 7,
        crossAxisSpacing: 20,
      ), 
      itemBuilder: (context, index){
        if(index < 7) return _weekDayTitle(index);
        if(_sequentialDates[index - 7].date == _selectedDateTime) 
          return _selector(_sequentialDates[index - 7]);
        return _calendarDates(_sequentialDates[index - 7]);
      },
    );
  }

  // calendar header
  Widget _weekDayTitle(int index){
    return Text(_weekDays[index], style: TextStyle(color: Colors.yellow, fontSize: 12),);
  }

  // calendar element
  Widget _calendarDates(Calendar calendarDate){
    return InkWell(
      onTap: (){
        if(_selectedDateTime != calendarDate.date){
          if(calendarDate.nextMonth){
            _getNextMonth();
          }
          else if(calendarDate.prevMonth){
            _getPrevMonth();
          }
          setState(() => _selectedDateTime = calendarDate.date);
        } 
      },
      child: Center(
        child: Text(
          '${calendarDate.date.day}', 
          style: TextStyle(
            color: (calendarDate.thisMonth) 
            ? (calendarDate.date.weekday == DateTime.sunday) ? Colors.yellow : Colors.white 
            : (calendarDate.date.weekday == DateTime.sunday) ? Colors.yellow.withOpacity(0.5) : Colors.white.withOpacity(0.5),
          ),
        )
      ),
    );
  }

  // date selector
  Widget _selector(Calendar calendarDate) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: Colors.white, width: 4),
        gradient: LinearGradient(
          colors: [Colors.black.withOpacity(0.1), Colors.white],
          stops: [0.1, 1],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Center(
          child: Text(
            '${calendarDate.date.day}',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w700
            ),
          ),
        ),
      ),
    );
  }

  // get next month calendar
  void _getNextMonth(){
    if(_currentDateTime.month == 12) {
      _currentDateTime = DateTime(_currentDateTime.year+1, 1);
    }
    else{
      _currentDateTime = DateTime(_currentDateTime.year, _currentDateTime.month+1);
    }
    _getCalendar();
  }

  // get previous month calendar
  void _getPrevMonth(){
    if(_currentDateTime.month == 1){
      _currentDateTime = DateTime(_currentDateTime.year-1, 12);
    }
    else{
      _currentDateTime = DateTime(_currentDateTime.year, _currentDateTime.month-1);
    }
    _getCalendar();
  }

  // get calendar for current month
  void _getCalendar(){
    _sequentialDates = CustomCalendar().getMonthCalendar(_currentDateTime.month, _currentDateTime.year, startWeekDay: StartWeekDay.monday);
  }

  // show months list
  Widget _showMonthsList(){
    return Column(
      children: <Widget>[
        InkWell(
          onTap: () => setState(() => _currentView = CalendarViews.year),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text('${_currentDateTime.year}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),),
          ),
        ),
        Divider(color: Colors.white,),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: _monthNames.length,
            itemBuilder: (context, index) => ListTile(
              onTap: (){
                _currentDateTime = DateTime(_currentDateTime.year, index+1);
                _getCalendar();
                setState(() => _currentView = CalendarViews.dates);
              },
              title: Center(
                child: Text(
                  _monthNames[index], 
                  style: TextStyle(fontSize: 18, color: (index == _currentDateTime.month-1) ? Colors.yellow : Colors.white),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // years list views
  Widget _yearsView(int midYear){
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            _toggleBtn(false),
            Spacer(),
            _toggleBtn(true),
          ],
        ),
        Expanded(
          child: GridView.builder(
            shrinkWrap: true,
            itemCount: 9,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
            ), 
            itemBuilder: (context, index){
              int thisYear;
              if(index < 4){
                thisYear = midYear - (4 - index);
              }
              else if(index > 4){
                thisYear = midYear + (index - 4);
              }
              else{
                thisYear = midYear;
              }
              return ListTile(
                onTap: (){
                  _currentDateTime = DateTime(thisYear, _currentDateTime.month);
                  _getCalendar();
                  setState(() => _currentView = CalendarViews.months);
                },
                title: Text(
                  '$thisYear', 
                  style: TextStyle(fontSize: 18, color: (thisYear == _currentDateTime.year) ? Colors.yellow : Colors.white),
                ),
              );
            }
          ),
        ),
      ],
    );
  }
}
