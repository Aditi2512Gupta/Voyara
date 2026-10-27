import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../data/models/expense_model.dart';
import '../../providers/expense_provider.dart';

class ExpensePage extends ConsumerWidget {
  const ExpensePage({
    super.key,
    required this.tripId,
    required this.budget,
    required this.plannedCost,
  });

  final String tripId;
  final double budget;
  final double plannedCost;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final expensesAsync = ref.watch(expensesProvider(tripId));

    return Scaffold(
      backgroundColor: isDark ? AppColors.scaffoldDark : AppColors.scaffoldLight,
      appBar: AppBar(
        title: const Text(
          "Trip Expenses",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => AddExpenseDialog(tripId: tripId),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Expense"),
      ),
      body: expensesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              error.toString(),
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ),
        data: (expenses) {
          final totalSpent = expenses.fold<double>(
            0,
            (sum, expense) => sum + expense.amount,
          );

          final difference = plannedCost - totalSpent;
          final isUnderPlan = difference >= 0;

          final remaining = budget - totalSpent;

          final categoryTotals = <String, double>{};

          for (final expense in expenses) {
            categoryTotals[expense.category] =
                (categoryTotals[expense.category] ?? 0) + expense.amount;
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
            children: [
              _buildBudgetCard(context, totalSpent, remaining, isDark),

              if (expenses.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildCategoryBreakdown(
                  context,
                  categoryTotals,
                  totalSpent,
                  isDark,
                ),
              ],

              const SizedBox(height: 16),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Planned vs Actual",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("AI Planned Cost"),
                          Text(
                            "₹${plannedCost.toStringAsFixed(0)}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Actual Spent"),
                          Text(
                            "₹${totalSpent.toStringAsFixed(0)}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isUnderPlan ? "Under Plan" : "Over Plan",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "₹${difference.abs().toStringAsFixed(0)}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isUnderPlan
                                  ? const Color(0xFF0E7A60)
                                  : AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              if (expenses.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: Text("No expenses added yet.")),
                  ),
                )
              else
                ...expenses.map(
                  (expense) => _buildExpenseTile(context, ref, expense, isDark),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryBreakdown(
    BuildContext context,
    Map<String, double> categoryTotals,
    double totalSpent,
    bool isDark,
  ) {
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Spending Breakdown",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...sortedCategories.map((entry) {
              final percentage =
                  totalSpent > 0 ? entry.value / totalSpent : 0.0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.key,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text(
                          "₹${entry.value.toStringAsFixed(0)}",
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: percentage,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(10),
                      backgroundColor:
                          isDark ? AppColors.inputDark : AppColors.inputLight,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetCard(
    BuildContext context,
    double totalSpent,
    double remaining,
    bool isDark,
  ) {
    final isOverBudget = remaining < 0;

    final budgetUsedPercentage = budget > 0
        ? (totalSpent / budget).clamp(0.0, 1.0)
        : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "Budget Overview",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _amountColumn("Budget", budget),
                _amountColumn("Spent", totalSpent),
                _amountColumn(
                  isOverBudget ? "Over Budget" : "Remaining",
                  remaining.abs(),
                  isOverBudget,
                ),
              ],
            ),
            const SizedBox(height: 20),
            LinearProgressIndicator(
              value: budgetUsedPercentage,
              minHeight: 8,
              borderRadius: BorderRadius.circular(10),
              backgroundColor:
                  isDark ? AppColors.inputDark : AppColors.inputLight,
              color: isOverBudget ? AppColors.error : AppColors.primary,
            ),
            const SizedBox(height: 8),
            Text(
              budget > 0
                  ? "${(totalSpent / budget * 100).toStringAsFixed(0)}% of budget used"
                  : "No budget set",
              style: TextStyle(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _amountColumn(String title, double amount, [bool warning = false]) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 6),
        Text(
          "₹${amount.toStringAsFixed(0)}",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: warning ? AppColors.error : null,
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseTile(
    BuildContext context,
    WidgetRef ref,
    ExpenseModel expense,
    bool isDark,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              isDark ? AppColors.scaffoldDark : AppColors.primarySurface,
          child: Icon(_categoryIcon(expense.category), color: AppColors.primary),
        ),
        title: Text(
          expense.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          "${expense.category} • "
          "${expense.date.day}/${expense.date.month}/${expense.date.year}",
          style: const TextStyle(color: AppColors.textSecondaryLight),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "₹${expense.amount.toStringAsFixed(0)}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => EditExpenseDialog(expense: expense),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: AppColors.error,
              onPressed: () async {
                await ref
                    .read(expenseRepositoryProvider)
                    .deleteExpense(expense.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case "Food":
        return Icons.restaurant;
      case "Transport":
        return Icons.directions_car;
      case "Hotel":
        return Icons.hotel;
      case "Tickets":
        return Icons.confirmation_num;
      case "Shopping":
        return Icons.shopping_bag;
      default:
        return Icons.receipt_long;
    }
  }
}

class AddExpenseDialog extends ConsumerStatefulWidget {
  const AddExpenseDialog({super.key, required this.tripId});

  final String tripId;

  @override
  ConsumerState<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends ConsumerState<AddExpenseDialog> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  String _category = "Food";
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Expense"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "Expense title",
                hintText: "e.g. Lunch",
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: "Amount",
                prefixText: "₹ ",
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(labelText: "Category"),
              items: const [
                DropdownMenuItem(value: "Food", child: Text("Food")),
                DropdownMenuItem(value: "Transport", child: Text("Transport")),
                DropdownMenuItem(value: "Hotel", child: Text("Hotel")),
                DropdownMenuItem(value: "Tickets", child: Text("Tickets")),
                DropdownMenuItem(value: "Shopping", child: Text("Shopping")),
                DropdownMenuItem(value: "Other", child: Text("Other")),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _category = value;
                  });
                }
              },
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: const Text("Date"),
              subtitle: Text(
                "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
              ),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                  initialDate: _selectedDate,
                );

                if (picked != null && mounted) {
                  setState(() {
                    _selectedDate = picked;
                  });
                }
              },
            ),
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: "Notes (optional)",
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Cancel"),
        ),
        FilledButton(
          onPressed: () async {
            final title = _titleController.text.trim();
            final amount = double.tryParse(_amountController.text.trim());

            if (title.isEmpty || amount == null || amount <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Enter a valid title and amount."),
                ),
              );
              return;
            }

            final expense = ExpenseModel(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              tripId: widget.tripId,
              title: title,
              category: _category,
              amount: amount,
              date: _selectedDate,
              notes: _notesController.text.trim(),
            );

            await ref.read(expenseRepositoryProvider).addExpense(expense);

            if (context.mounted) {
              Navigator.pop(context);
            }
          },
          child: const Text("Add"),
        ),
      ],
    );
  }
}

class EditExpenseDialog extends ConsumerStatefulWidget {
  const EditExpenseDialog({super.key, required this.expense});

  final ExpenseModel expense;

  @override
  ConsumerState<EditExpenseDialog> createState() => _EditExpenseDialogState();
}

class _EditExpenseDialogState extends ConsumerState<EditExpenseDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _notesController;

  late String _category;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.expense.title);
    _amountController =
        TextEditingController(text: widget.expense.amount.toString());
    _notesController = TextEditingController(text: widget.expense.notes);
    _category = widget.expense.category;
    _selectedDate = widget.expense.date;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit Expense"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "Expense title",
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: "Amount",
                prefixText: "₹ ",
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(labelText: "Category"),
              items: const [
                DropdownMenuItem(value: "Food", child: Text("Food")),
                DropdownMenuItem(value: "Transport", child: Text("Transport")),
                DropdownMenuItem(value: "Hotel", child: Text("Hotel")),
                DropdownMenuItem(value: "Tickets", child: Text("Tickets")),
                DropdownMenuItem(value: "Shopping", child: Text("Shopping")),
                DropdownMenuItem(value: "Other", child: Text("Other")),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _category = value;
                  });
                }
              },
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: const Text("Date"),
              subtitle: Text(
                "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
              ),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                  initialDate: _selectedDate,
                );

                if (picked != null && mounted) {
                  setState(() {
                    _selectedDate = picked;
                  });
                }
              },
            ),
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: "Notes (optional)",
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Cancel"),
        ),
        FilledButton(
          onPressed: () async {
            final title = _titleController.text.trim();
            final amount = double.tryParse(_amountController.text.trim());

            if (title.isEmpty || amount == null || amount <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Enter a valid title and amount."),
                ),
              );
              return;
            }

            final updatedExpense = ExpenseModel(
              id: widget.expense.id,
              tripId: widget.expense.tripId,
              title: title,
              category: _category,
              amount: amount,
              date: _selectedDate,
              notes: _notesController.text.trim(),
            );

            await ref
                .read(expenseRepositoryProvider)
                .updateExpense(updatedExpense);

            if (context.mounted) {
              Navigator.pop(context);
            }
          },
          child: const Text("Save Changes"),
        ),
      ],
    );
  }
}
