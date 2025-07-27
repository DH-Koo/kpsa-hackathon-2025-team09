import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/medication.dart';
import '../../providers/medication_check_log_provider.dart';

class MedicationDayCard extends StatefulWidget {
  final Future<List<MedicationRoutine>> routinesFuture;
  final List<DateTime> weekDates;
  final int selectedDayIndex;
  final String selectedDayStr;
  final int userId;
  final DateTime selectedDate;
  final void Function(DateTime)? onDateSelected;

  const MedicationDayCard({
    super.key,
    required this.routinesFuture,
    required this.weekDates,
    required this.selectedDayIndex,
    required this.selectedDayStr,
    required this.userId,
    required this.selectedDate,
    this.onDateSelected,
  });

  @override
  State<MedicationDayCard> createState() => _MedicationDayCardState();
}

class _MedicationDayCardState extends State<MedicationDayCard> {
  // TODO: 임시로 만든 퍼센트에 따라 이모지 아이콘 반환 함수
  IconData getEmojiIconByPercent(int percent) {
    if (percent == 0) {
      return Icons.sentiment_very_dissatisfied; // 우는 이모티콘
    } else if (percent <= 33) {
      return Icons.sentiment_neutral; // 일반표정
    } else if (percent <= 66) {
      return Icons.sentiment_satisfied; // 웃음
    } else if (percent < 100) {
      return Icons.sentiment_very_satisfied; // 활짝 웃음
    } else {
      return Icons.celebration; // 완료 이모티콘
    }
  }

  bool isFutureDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    return target.isAfter(today);
  }

  @override
  Widget build(BuildContext context) {
    final days = ['월', '화', '수', '목', '금', '토', '일'];
    final selectedDateStr =
        "${widget.selectedDate.year.toString().padLeft(4, '0')}-${widget.selectedDate.month.toString().padLeft(2, '0')}-${widget.selectedDate.day.toString().padLeft(2, '0')}";

    return Consumer<MedicationCheckLogProvider>(
      builder: (context, checkLogProvider, child) {
        return FutureBuilder<List<MedicationRoutine>>(
          future: widget.routinesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(32.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 48),
                      SizedBox(height: 16),
                      Text(
                        '약 정보를 불러오는데 실패했습니다',
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${snapshot.error}',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            // null 체크 추가
            if (!snapshot.hasData || snapshot.data == null) {
              return Padding(
                padding: const EdgeInsets.all(32.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.medication_outlined,
                        color: Colors.grey,
                        size: 48,
                      ),
                      SizedBox(height: 16),
                      Text(
                        '등록된 약이 없습니다',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '약을 등록해주세요',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              );
            }

            final routines = snapshot.data!;

            // 임시: 모든 루틴을 표시 (필터링 조건 완화)
            var todaysRoutines = routines;

            // 만약 루틴이 없고 checkLogs가 있다면, checkLogs를 기반으로 임시 루틴 생성
            if (todaysRoutines.isEmpty &&
                checkLogProvider.checkLogs.isNotEmpty) {
              // checkLogs에서 고유한 medicine ID들을 추출
              final uniqueMedicineIds = checkLogProvider.checkLogs
                  .map((log) => log.medicine)
                  .toSet()
                  .toList();

              // 각 medicine ID에 대해 임시 루틴 생성
              todaysRoutines = uniqueMedicineIds.map((medicineId) {
                // 해당 medicine의 모든 시간을 수집
                final times = checkLogProvider.checkLogs
                    .where((log) => log.medicine == medicineId)
                    .map((log) => log.time)
                    .toSet()
                    .toList();

                return MedicationRoutine(
                  id: medicineId,
                  userId: widget.userId,
                  name: '약 $medicineId',
                  takeTime: times,
                  numPerTake: 1,
                  numPerDay: times.length,
                  totalDays: 1,
                  weekday: [widget.selectedDayStr],
                  startDay: widget.selectedDate,
                  endDay: widget.selectedDate.add(const Duration(days: 1)),
                );
              }).toList();
            }

            // 원래 필터링 조건 (주석 처리)
            /*
            final todaysRoutines = routines.where((r) {
              final weekdayMatch = r.weekday.contains(widget.selectedDayStr);
              final startDayMatch = !widget.selectedDate.isBefore(r.startDay);
              final endDayMatch = widget.selectedDate.isBefore(r.endDay);

              print(
                '[MedicationDayCard] 루틴 ${r.id} 필터링 - weekdayMatch: $weekdayMatch, startDayMatch: $startDayMatch, endDayMatch: $endDayMatch',
              );
              print(
                '[MedicationDayCard] 루틴 ${r.id} 날짜 비교 - selectedDate: ${widget.selectedDate}, startDay: ${r.startDay}, endDay: ${r.endDay}',
              );

              return weekdayMatch && startDayMatch && endDayMatch;
            }).toList();
            */

            // percent 계산
            final int totalCount = todaysRoutines.fold(
              0,
              (sum, r) => sum + r.takeTime.length,
            );
            final int checkedCount = todaysRoutines.fold(
              0,
              (sum, r) =>
                  sum +
                  r.takeTime
                      .where(
                        (time) => checkLogProvider.isCheckedTime(r.id, time),
                      )
                      .length,
            );
            final int percent = totalCount == 0
                ? 0
                : ((checkedCount / totalCount) * 100).round();

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF232329),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () async {
                                    if (widget.onDateSelected != null) {
                                      widget.onDateSelected!(
                                        widget.selectedDate,
                                      );
                                    }
                                  },
                                  child: Row(
                                    children: [
                                      Text(
                                        '${widget.selectedDate.month}월 ${widget.selectedDate.day}일 (${days[widget.selectedDate.weekday - 1]})',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.arrow_drop_down,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // 기존 이모지 아이콘
                              if (!isFutureDate(widget.selectedDate) &&
                                  todaysRoutines.isNotEmpty)
                                Icon(
                                  getEmojiIconByPercent(percent),
                                  color: Colors.white,
                                  size: 28,
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (todaysRoutines.isEmpty)
                            Column(
                              children: [
                                const Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 32),
                                    child: Text(
                                      '복약 루틴이 없습니다.',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                                // 임시: checkLogs 데이터 표시
                                if (checkLogProvider.checkLogs.isNotEmpty) ...[
                                  const SizedBox(height: 16),
                                  const Text(
                                    '체크 로그 데이터 (임시):',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ...checkLogProvider.checkLogs
                                      .take(10)
                                      .map(
                                        (log) => Container(
                                          margin: const EdgeInsets.symmetric(
                                            vertical: 2,
                                          ),
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Color(0xFF393939),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            '약 ID: ${log.medicine}, 시간: ${log.time}, 복용: ${log.isTaken}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                ],
                              ],
                            )
                          else
                            ...todaysRoutines.map((routine) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ...routine.takeTime.map((time) {
                                    final checked = checkLogProvider
                                        .isCheckedTime(routine.id, time);
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4.0,
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xFF393939),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        // IntrinsicHeight로 자동 부모 높이에 맞춤
                                        child: IntrinsicHeight(
                                          child: Row(
                                            children: [
                                              // 왼쪽 컬러 바: animate 없이 바로 사라짐
                                              !checked
                                                  ? Container(
                                                      width: 8,
                                                      decoration: const BoxDecoration(
                                                        color: Color.fromARGB(
                                                          255,
                                                          152,
                                                          205,
                                                          91,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.horizontal(
                                                              left:
                                                                  Radius.circular(
                                                                    12,
                                                                  ),
                                                            ),
                                                      ),
                                                    )
                                                  : const SizedBox(width: 0),
                                              Expanded(
                                                child: ListTile(
                                                  contentPadding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                      ),
                                                  title: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          left: 12,
                                                        ),
                                                    child: Text(
                                                      routine.name,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 15,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                  subtitle: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          left: 12,
                                                        ),
                                                    child: Text(
                                                      '${time[0].toString().padLeft(2, '0')}:${time[1].toString().padLeft(2, '0')}',
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        color: Colors.grey[300],
                                                      ),
                                                    ),
                                                  ),
                                                  trailing:
                                                      isFutureDate(
                                                        widget.selectedDate,
                                                      )
                                                      ? null
                                                      : Icon(
                                                          checked
                                                              ? Icons.check
                                                              : Icons
                                                                    .crop_square,
                                                          color: checked
                                                              ? const Color.fromARGB(
                                                                  255,
                                                                  152,
                                                                  205,
                                                                  91,
                                                                )
                                                              : Colors
                                                                    .grey[300],
                                                          size: 28,
                                                        ),
                                                  onTap:
                                                      isFutureDate(
                                                        widget.selectedDate,
                                                      )
                                                      ? null
                                                      : () async {
                                                          await checkLogProvider
                                                              .toggleCheck(
                                                                widget.userId,
                                                                selectedDateStr,
                                                                routine.id,
                                                                time,
                                                              );
                                                          // markNeedsBuild() 제거 - Consumer가 자동으로 업데이트
                                                        },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              );
                            }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
