import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final expensesAsync = ref.watch(expensesProvider(tripId));

    return Scaffold(
      appBar: AppBar(title: const Text("Trip Expenses")),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddExpenseDialog(context, ref);
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Expense"),
      ),
      body: expensesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
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
            padding: const EdgeInsets.all(16),
            children: [
              _buildBudgetCard(context, totalSpent, remaining),

              if (expenses.isNotEmpty) ...[
                const SizedBox(height: 20),

                _buildCategoryBreakdown(context, categoryTotals, totalSpent),
              ],

              const SizedBox(height: 20),

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
                              color: isUnderPlan ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              if (expenses.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: Text("No expenses added yet.")),
                  ),
                )
              else
                ...expenses.map(
                  (expense) => _buildExpenseTile(context, ref, expense),
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
              final percentage = totalSpent > 0
                  ? entry.value / totalSpent
                  : 0.0;

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
                        Text("₹${entry.value.toStringAsFixed(0)}"),
                      ],
                    ),

                    const SizedBox(height: 6),

                    LinearProgressIndicator(
                      value: percentage,
                      minHeight: 7,
                      borderRadius: BorderRadius.circular(10),
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
            ),

            const SizedBox(height: 8),

            Text(
              budget > 0
                  ? "${(totalSpent / budget * 100).toStringAsFixed(0)}% of budget used"
                  : "No budget set",
              style: TextStyle(color: Colors.grey.shade700),
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
            color: warning ? Colors.red : null,
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseTile(
    BuildContext context,
    WidgetRef ref,
    ExpenseModel expense,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(child: Icon(_categoryIcon(expense.category))),
        title: Text(expense.title),
        subtitle: Text(
          "${expense.category} • "
          "${expense.date.day}/${expense.date.month}/${expense.date.year}",
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
                _showEditExpenseDialog(context, ref, expense);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
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

  Future<void> _showAddExpenseDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final notesController = TextEditingController();

    String category = "Food";
    DateTime selectedDate = DateTime.now();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Add Expense"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: "Expense title",
                        hintText: "e.g. Lunch",
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: amountController,
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
                      value: category,
                      decoration: const InputDecoration(labelText: "Category"),
                      items: const [
                        DropdownMenuItem(value: "Food", child: Text("Food")),
                        DropdownMenuItem(
                          value: "Transport",
                          child: Text("Transport"),
                        ),
                        DropdownMenuItem(value: "Hotel", child: Text("Hotel")),
                        DropdownMenuItem(
                          value: "Tickets",
                          child: Text("Tickets"),
                        ),
                        DropdownMenuItem(
                          value: "Shopping",
                          child: Text("Shopping"),
                        ),
                        DropdownMenuItem(value: "Other", child: Text("Other")),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            category = value;
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
                        "${selectedDate.day}/"
                        "${selectedDate.month}/"
                        "${selectedDate.year}",
                      ),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                          initialDate: selectedDate,
                        );

                        if (picked != null) {
                          setDialogState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                    ),

                    TextField(
                      controller: notesController,
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
                    Navigator.pop(dialogContext);
                  },
                  child: const Text("Cancel"),
                ),
                FilledButton(
                  onPressed: () async {
                    final title = titleController.text.trim();

                    final amount = double.tryParse(
                      amountController.text.trim(),
                    );

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
                      tripId: tripId,
                      title: title,
                      category: category,
                      amount: amount,
                      date: selectedDate,
                      notes: notesController.text.trim(),
                    );

                    await ref
                        .read(expenseRepositoryProvider)
                        .addExpense(expense);

                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                    }
                  },
                  child: const Text("Add"),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
    amountController.dispose();
    notesController.dispose();
  }

  Future<void> _showEditExpenseDialog(
    BuildContext context,
    WidgetRef ref,
    ExpenseModel expense,
  ) async {
    final titleController = TextEditingController(text: expense.title);

    final amountController = TextEditingController(
      text: expense.amount.toString(),
    );

    final notesController = TextEditingController(text: expense.notes);

    String category = expense.category;
    DateTime selectedDate = expense.date;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Edit Expense"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: "Expense title",
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: amountController,
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
                      value: category,
                      decoration: const InputDecoration(labelText: "Category"),
                      items: const [
                        DropdownMenuItem(value: "Food", child: Text("Food")),
                        DropdownMenuItem(
                          value: "Transport",
                          child: Text("Transport"),
                        ),
                        DropdownMenuItem(value: "Hotel", child: Text("Hotel")),
                        DropdownMenuItem(
                          value: "Tickets",
                          child: Text("Tickets"),
                        ),
                        DropdownMenuItem(
                          value: "Shopping",
                          child: Text("Shopping"),
                        ),
                        DropdownMenuItem(value: "Other", child: Text("Other")),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            category = value;
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
                        "${selectedDate.day}/"
                        "${selectedDate.month}/"
                        "${selectedDate.year}",
                      ),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                          initialDate: selectedDate,
                        );

                        if (picked != null) {
                          setDialogState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                    ),

                    TextField(
                      controller: notesController,
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
                    Navigator.pop(dialogContext);
                  },
                  child: const Text("Cancel"),
                ),

                FilledButton(
                  onPressed: () async {
                    final title = titleController.text.trim();

                    final amount = double.tryParse(
                      amountController.text.trim(),
                    );

                    if (title.isEmpty || amount == null || amount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Enter a valid title and amount."),
                        ),
                      );
                      return;
                    }

                    final updatedExpense = ExpenseModel(
                      id: expense.id,
                      tripId: expense.tripId,
                      title: title,
                      category: category,
                      amount: amount,
                      date: selectedDate,
                      notes: notesController.text.trim(),
                    );

                    await ref
                        .read(expenseRepositoryProvider)
                        .updateExpense(updatedExpense);

                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                    }
                  },
                  child: const Text("Save Changes"),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
    amountController.dispose();
    notesController.dispose();
  }
}
