import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../state/organizer_store.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class CreateEventScreen extends StatefulWidget {
  static const String routeName = '/create-event';
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _venueController = TextEditingController();
  final _contactInfoController = TextEditingController();
  final _rulesController = TextEditingController();
  final _capacityController = TextEditingController();
  
  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _waitlistEnabled = false;
  bool _isLoading = false;
  int? _selectedCategoryId;
  int? _selectedDepartmentId;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _venueController.dispose();
    _contactInfoController.dispose();
    _rulesController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Tạo sự kiện mới',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF6C63FF),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : () => Navigator.pop(context),
            child: const Text(
              'Hủy',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Thông tin cơ bản'),
              _buildBasicInfoSection(),
              
              const SizedBox(height: 24),
              _buildSectionTitle('Thời gian và địa điểm'),
              _buildDateTimeSection(),
              
              const SizedBox(height: 24),
              _buildSectionTitle('Phân loại sự kiện'),
              _buildCategorySection(),
              
              const SizedBox(height: 24),
              _buildSectionTitle('Cài đặt sự kiện'),
              _buildEventSettingsSection(),
              
              const SizedBox(height: 24),
              _buildSectionTitle('Thông tin bổ sung'),
              _buildAdditionalInfoSection(),
              
              const SizedBox(height: 32),
              _buildCreateButton(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2D3748),
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTextField(
              controller: _titleController,
              label: 'Tên sự kiện *',
              hint: 'Nhập tên sự kiện',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập tên sự kiện';
                }
                if (value.trim().length < 5) {
                  return 'Tên sự kiện phải có ít nhất 5 ký tự';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _descriptionController,
              label: 'Mô tả sự kiện',
              hint: 'Mô tả chi tiết về sự kiện...',
              maxLines: 4,
              validator: (value) {
                if (value != null && value.trim().length > 1000) {
                  return 'Mô tả không được quá 1000 ký tự';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildDateField(
                    label: 'Ngày bắt đầu *',
                    date: _startDate,
                    onTap: () => _selectStartDate(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTimeField(
                    label: 'Giờ bắt đầu *',
                    time: _startTime,
                    onTap: () => _selectStartTime(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDateField(
                    label: 'Ngày kết thúc *',
                    date: _endDate,
                    onTap: () => _selectEndDate(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTimeField(
                    label: 'Giờ kết thúc *',
                    time: _endTime,
                    onTap: () => _selectEndTime(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _venueController,
              label: 'Địa điểm *',
              hint: 'Nhập địa điểm tổ chức',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập địa điểm';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildDropdownField(
              label: 'Danh mục sự kiện *',
              value: _selectedCategoryId,
              items: const [
                DropdownMenuItem(value: 1, child: Text('Công nghệ')),
                DropdownMenuItem(value: 2, child: Text('Giáo dục')),
                DropdownMenuItem(value: 3, child: Text('Kinh doanh')),
                DropdownMenuItem(value: 4, child: Text('Nghệ thuật')),
                DropdownMenuItem(value: 5, child: Text('Thể thao')),
                DropdownMenuItem(value: 6, child: Text('Khác')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCategoryId = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Vui lòng chọn danh mục sự kiện';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildDropdownField(
              label: 'Khoa/Ban *',
              value: _selectedDepartmentId,
              items: const [
                DropdownMenuItem(value: 1, child: Text('Khoa Công nghệ thông tin')),
                DropdownMenuItem(value: 2, child: Text('Khoa Kinh tế')),
                DropdownMenuItem(value: 3, child: Text('Khoa Ngoại ngữ')),
                DropdownMenuItem(value: 4, child: Text('Khoa Khoa học xã hội')),
                DropdownMenuItem(value: 5, child: Text('Khác')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedDepartmentId = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Vui lòng chọn khoa/ban';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventSettingsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTextField(
              controller: _capacityController,
              label: 'Số lượng tham gia tối đa *',
              hint: 'Nhập số lượng',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập số lượng tham gia';
                }
                final capacity = int.tryParse(value);
                if (capacity == null || capacity <= 0) {
                  return 'Số lượng phải là số dương';
                }
                if (capacity > 10000) {
                  return 'Số lượng không được quá 10000';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text(
                'Bật danh sách chờ',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: const Text(
                'Cho phép đăng ký khi hết chỗ',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              value: _waitlistEnabled,
              onChanged: (value) {
                setState(() {
                  _waitlistEnabled = value;
                });
              },
              activeColor: const Color(0xFF6C63FF),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfoSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTextField(
              controller: _contactInfoController,
              label: 'Thông tin liên hệ',
              hint: 'Email, số điện thoại...',
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _rulesController,
              label: 'Quy định sự kiện',
              hint: 'Các quy định, lưu ý cho người tham gia...',
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required int? value,
    required List<DropdownMenuItem<int>> items,
    required ValueChanged<int?> onChanged,
    String? Function(int?)? validator,
  }) {
    return DropdownButtonFormField<int>(
      value: value,
      items: items,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          suffixIcon: const Icon(Icons.calendar_today, color: Color(0xFF6C63FF)),
        ),
        child: Text(
          date != null
              ? '${date.day}/${date.month}/${date.year}'
              : 'Chọn ngày',
          style: TextStyle(
            color: date != null ? Colors.black : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeField({
    required String label,
    required TimeOfDay? time,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          suffixIcon: const Icon(Icons.access_time, color: Color(0xFF6C63FF)),
        ),
        child: Text(
          time != null
              ? time.format(context)
              : 'Chọn giờ',
          style: TextStyle(
            color: time != null ? Colors.black : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: FilledButton(
        onPressed: _isLoading ? null : _createEvent,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF6C63FF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Tạo sự kiện',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _startDate = date;
        // Nếu ngày kết thúc trước ngày bắt đầu, reset ngày kết thúc
        if (_endDate != null && _endDate!.isBefore(date)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _endDate = date;
      });
    }
  }

  Future<void> _selectStartTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
    );
    if (time != null) {
      setState(() {
        _startTime = time;
      });
    }
  }

  Future<void> _selectEndTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _endTime ?? TimeOfDay.now(),
    );
    if (time != null) {
      setState(() {
        _endTime = time;
      });
    }
  }

  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_startDate == null || _startTime == null) {
      _showErrorDialog('Vui lòng chọn ngày và giờ bắt đầu');
      return;
    }

    if (_endDate == null || _endTime == null) {
      _showErrorDialog('Vui lòng chọn ngày và giờ kết thúc');
      return;
    }

    // Tạo DateTime từ date và time
    final startDateTime = DateTime(
      _startDate!.year,
      _startDate!.month,
      _startDate!.day,
      _startTime!.hour,
      _startTime!.minute,
    );

    final endDateTime = DateTime(
      _endDate!.year,
      _endDate!.month,
      _endDate!.day,
      _endTime!.hour,
      _endTime!.minute,
    );

    if (endDateTime.isBefore(startDateTime)) {
      _showErrorDialog('Thời gian kết thúc phải sau thời gian bắt đầu');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get current user ID as organizer_id
      final authService = context.read<AuthService>();
      final currentUser = authService.currentUser;
      
      if (currentUser == null) {
        _showErrorDialog('Không thể lấy thông tin người dùng. Vui lòng đăng nhập lại.');
        return;
      }

      final eventData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        'venue': _venueController.text.trim(),
        'contact_info': _contactInfoController.text.trim().isEmpty 
            ? null 
            : _contactInfoController.text.trim(),
        'rules': _rulesController.text.trim().isEmpty 
            ? null 
            : _rulesController.text.trim(),
        'start_at': startDateTime.toIso8601String(),
        'end_at': endDateTime.toIso8601String(),
        'capacity': int.parse(_capacityController.text.trim()),
        'waitlist_enabled': _waitlistEnabled ? 1 : 0,
        'category_id': _selectedCategoryId,
        'department_id': _selectedDepartmentId,
        'organizer_id': currentUser['id'],
      };

      final response = await ApiService.instance.post('/events', eventData);
      
      if (response['success'] == true) {
        // Refresh events list
        if (mounted) {
          context.read<OrganizerStore>().loadEvents();
        }
        
        if (mounted) {
          _showSuccessDialog();
        }
      } else {
        if (mounted) {
          _showErrorDialog(response['message'] ?? 'Có lỗi xảy ra khi tạo sự kiện');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Có lỗi xảy ra: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lỗi'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thành công'),
        content: const Text('Sự kiện đã được tạo thành công!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to organizer dashboard
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
