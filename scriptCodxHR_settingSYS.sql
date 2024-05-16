use codxhr

--// Danh sách function Portal-HỒ SƠ CÁ NHÂN
	select FunctionID, DefaultName, TreeLevel, ParentID, Module, A.EntityName, FormName, GridViewName, url, LargeIcon, B.TableName
	from SYS_FunctionList A LEFT JOIN SYS_Entities B ON A.EntityName = B.EntityName
	where A.CreatedBy like 'ntpthaoCodx%' and A.Language='VN' and FunctionID like 'WSHREM%'

--=================================================================================================
--*** Xem cấu trúc table
	Exec spBA_ViewTableDesc @TableName='HR_Employees'  --// truyền tên table cần xem cấu trúc


--=================================================================================================
--*** Xem data setting GridViewSetup
	/* Diễn giải ý nghĩa field:
		 - HeaderText	: nội dung caption của field
		 - ControlType	: loại control (TextBox, ComboBox, CheckBox, ...)
		 - ReferedType	: loại tham chiếu: 2: Valuelist (viết tắt: vll) ; 3: Combobox (viết tắt: cbx)
		 - ReferedValue	: Mã vll, cbx:
			+ Nếu ReferedType=2: ReferedValue là mã vll, ref.: SYS_Valuelist.ListName
			+ Nếu ReferedType=3: ReferedValue là mã cbx, ref.: SYS_ComboboxList.ComboboxName
	*/

	Select GridViewName, FormName, EntityName, FieldName, ColumnName, HeaderText, ControlName, ControlType, DataType, DataFormat, ReferedType, ReferedValue, ColumnOrder, SortOrder
	From SYS_GridViewSetup
	Where GridViewName = 'grvEmpListPortal'  --// truyền tên gridview cần xem setting GridViewSetup


--=================================================================================================
--*** Xem data setting Combobox
	/* Diễn giải ý nghĩa field:
		 - TableName		: tên bảng lấy dữ liệu
		 - TableFields		: các field sử dụng trong xử lý
		 - DisplayMembers	: danh sách field hiển thị (theo thứ tự khai báo) khi open cbx (dropdown or popup)
		 - ValueMember		: field lưu
		 - ViewMember		: field hiển thị
		 - FieldFilter		: field lọc dữ liệu khi gõ lên vùng text. Note: thường gán = DisplayMembers (i.e., thấy gì thì lọc được đó)
		 - FieldSorting		: field sắp xếp
		 - SortingDirection	: chiều sắp xếp (tăng dần, giảm dần)
		 - Predicate		: điều kiện lọc datasource
		 - Validation		: =1: kiểm tra data phải thuộc tablesource.
	*/
	Select * from SYS_ComboboxList Where ComboboxName = 'HRDepts' --// truyền mã cbx


--=================================================================================================
--*** Xem data setting Valuelist
	/* Diễn giải ý nghĩa field:
		 - ListType			: =1: mỗi item gồm 1 phần (Value) ; =2: mỗi item gồm 2 phần (Value, Name)
		 - DefaultValues, CustomValues: danh sách giá trị valuelist
		 - IconSet			: icon
		 - ColorSet			: màu background
		 - TextColorSet		: màu chữ + icon
	*/
	Select * from SYS_Valuelist Where ListName = 'HR001' --// truyền mã vll


