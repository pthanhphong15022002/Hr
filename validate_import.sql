USE [codx_hr]
GO
/****** Object:  StoredProcedure [dbo].[HCSSYS_spImportValidateHSNV]    Script Date: 12/26/2024 10:46:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[HR_spImportValidateHSNV]
(      
	@UserID NVARCHAR(100)='admin',      
	@TableName NVARCHAR(250) = 'HCSEM_EmpContract',      
	@Xml XML = N'<ArrayOfObjImp>',      
	@Lang NVARCHAR(10) = 'VN',      
	@Error NVARCHAR(MAX) OUT,      
	@Field NVARCHAR(100) OUT,      
	@Val NVARCHAR(100) OUT,      
	@BUCodes NVARCHAR(MAX) OUT      
)      
AS      
BEGIN      
	--SELECT @TableName AS '@TableName'
	SET @Error = ''    
	--SELECT A.MsgID AS Value, A.MsgCode AS Code, A.MsgCaption AS Caption INTO #TEMP      
	--FROM HCSSYS_MsgBox A Where A.FunctionID = N'HCSSYS_spImportValidateHSNV'    

	SET @Field = ''      
	SET @Val = ''      
	--IF ISNULL(@TableName,'') = 'HCSEM_EmpTask_tmp' OR ISNULL(@TableName,'') = 'HCSEM_EmpTaskHeSo_tmp' OR ISNULL(@TableName,'') = 'HCSEM_EmpTaskTreChuyen_tmp'      
	--begin      
	--IF EXISTS (SELECT 1 FROM dbo.HCSSYS_SettingsForCustomers WHERE KeyCode='IsImportSanPhamChuyenBayViags' AND Value = 1)      
	--BEGIN      
	--	EXEC HCSSYS_spImportValidateHSNV_SanPhamChuyenBay_viags @UserID, @TableName, @Xml, @Lang, @Error OUT, @Field OUT, @Val OUT, @BUCodes out      
	--	RETURN      
	--END      
	--END		
    DECLARE @DowCode VARCHAR(7), @dddd VARCHAR(10), @Code VARCHAR(20)
	DECLARE @HSNV_IsValidateCMND BIT      
	SELECT @HSNV_IsValidateCMND = HSNV_IsValidateCMND FROM HR_ConfigEM WITH(NOLOCK)      
	DECLARE @result INT
	DECLARE @ResultPPhone INT
	DECLARE @ResultUserID_LoginAcc INT
	DECLARE @ResultMobile INT
	DECLARE @ResultTPhone INT
	DECLARE @ResultJobPhone INT
	DECLARE @resultEmail INT
	DECLARE @resultEmailPer INT
	DECLARE @MobileNV NVARCHAR(max)
	DECLARE @PPhoneNV NVARCHAR(max)
	DECLARE @TPhoneNV NVARCHAR(max)
	DECLARE @JobPhoneTN NVARCHAR(max)
	DECLARE @PPhoneTN NVARCHAR(max)
	DECLARE @TPhoneTN NVARCHAR(max)
	DECLARE @Birthday NVARCHAR(max)
	DECLARE @date DATETIME    
	DECLARE @FromDate DATETIME
	DECLARE @ToDate DATETIME
	DECLARE @UserCode NVARCHAR(20)
	SELECT @UserCode = EmployeeID FROM dbo.HR_Employees --WHERE UserID = @UserID

	DECLARE @WorkDate NVARCHAR(10), @FlightCode NVARCHAR(30), @RelatedFlight NVARCHAR(30), @ProductCode NVARCHAR(30), @EmpCode NVARCHAR(30),      
				@Quantity NVARCHAR(100),@Amount NVARCHAR(100), @DeptCode NVARCHAR(100)      
	
	--IF ISNULL(@TableName,'') = 'HCSPR_ProductEmpDateSalary_Exporttmp'      
	--BEGIN      
	--	--import luong san pham ha noi      
	--	SELECT @WorkDate = S.WorkDate, @FlightCode =S.FlightCode, @RelatedFlight = s.RelatedFlight, @ProductCode = S.ProductCode, @EmpCode = S.EmployeeCode,      
	--	@Quantity = S.Quantity, @Amount =S.Amount, @DeptCode = S.DeptCode      
	--	FROM      
	--	(      
	--		select T.N.value('WorkDate[1]', 'nvarchar(10)') as WorkDate,      
	--		T.N.value('FlightCode[1]', 'nvarchar(100)') as FlightCode,      
	--		T.N.value('RelatedFlight[1]', 'nvarchar(100)') as RelatedFlight,      
	--		T.N.value('ProductCode[1]', 'nvarchar(100)') as ProductCode,      
	--		T.N.value('EmployeeCode[1]', 'nvarchar(100)') as EmployeeCode,      
	--		T.N.value('Quantity[1]', 'nvarchar(100)') as Quantity,      
	--		T.N.value('Amount[1]', 'nvarchar(100)') as Amount,      
	--		T.N.value('DeptCode[1]', 'nvarchar(100)') as DeptCode      
	--		from @Xml.nodes('//FlightIP') as T(N)      
	--	) S      
	--	DECLARE @Airport NVARCHAR(100)      
	--	SELECT @Airport = CAP2_Code FROM dbo.HCSSYS_VWDepartmentFullInfo WHERE DepartmentCode =@DeptCode      
      
	--	IF(ISNULL(@WorkDate,'') = '' OR ISDATE(@WorkDate) <> 1)      
	--	BEGIN      
	--		--SET @Error = N'Ngày không được trống.'    
	--		SELECT @Error = ISNULL(Code,'')     
	--		FROM #TEMP WHERE Value=1    
	--		RETURN      
	--	END      
  
	--	IF(ISNULL(@ProductCode,'') = '')      
	--	BEGIN      
	--		--SET @Error = N'Mã sản phẩm không được trống'    
	--		SELECT @Error = ISNULL(Code,'')     
	--		FROM #TEMP WHERE Value=2    
	--		RETURN      
	--	END       
	--	--IF NOT EXISTS (SELECT 1 FROM dbo.HCSLS_Product WHERE ProductCode=@ProductCode)      
	--	--BEGIN      
	--	-- SET @Error = N'Không tìm mả sản phẩm trong danh mục sản phẩm'      
	--	-- RETURN      
	--	--END      
	--	IF @Quantity = '0' OR ISNULL(@Quantity,'') = ''      
	--	BEGIN      
	--		--SET @Error = N'Chưa nhập tỉ lệ tham gia'    
	--		SELECT @Error = ISNULL(Code,'')     
	--		FROM #TEMP WHERE Value=3    
	--		RETURN      
	--	END      
	--	IF @Amount = '0' OR ISNULL(@Amount,'') = ''      
	--	BEGIN      
	--		--SET @Error = N'Chưa nhập thành tiền'    
	--		SELECT @Error = ISNULL(Code,'')     
	--		FROM #TEMP WHERE Value=4    
	--		RETURN      
	--	END      
	--	--SELECT @EmpCode      
	--	IF NOT EXISTS (SELECT 1 FROM dbo.HCSSYS_FNGetChildDepartments(@DeptCode) P INNER JOIN dbo.HCSEM_Employees E ON E.DepartmentCode = E.DepartmentCode WHERE E.EmployeeCode =@EmpCode)      
	--	BEGIN      
	--		--SET @Error = N'Mã nhân viên không tìm thấy trong bộ phận đang chọn'    
	--		SELECT @Error = ISNULL(Code,'')     
	--		FROM #TEMP WHERE Value=5    
	--		RETURN      
	--	END      
      
	--	IF EXISTS (select 1 from HCSSYS_UserLockData_fnCheckLock(@UserID,@WorkDate,@WorkDate,'HCSTS31') WHERE DepartmentCode = @DeptCode)      
	--	BEGIN      
	--		--SET @Error = N'Dữ liệu nằm trong kỳ đã bị khóa.'    
	--		SELECT @Error = ISNULL(Code,'')     
	--		FROM #TEMP WHERE Value=6    
	--		RETURN      
	--	END      
      
	--	INSERT INTO dbo.HCSPR_ProductEmpDateSalary_Exporttmp      
	--			( WorkDate ,  FlightCode ,  RelatedFlight , ProductCode , EmployeeCode ,  Quantity , Amount ,  UserID ,  CreatedOn , CreatedBy)      
	--	VALUES  ( @WorkDate, @FlightCode, @RelatedFlight, @ProductCode, @EmpCode, @Quantity, @Amount, @UserID, GETDATE(), @UserID)      
      
	--	RETURN      
	--END      
      
	 select T.N.value('Field[1]', 'nvarchar(100)') as FieldName,      
	   Replace(RTRIM(T.N.value('Value[1]', 'nvarchar(100)')),char(10),'') as CodeValue      
	 INTO #lstOfField      
	 from @Xml.nodes('//ArrayOfObjImp/ObjImp') as T(N)      
	 WHERE ISNULL(T.N.value('Value[1]', 'nvarchar(100)'),'') <> '' 
 
	 DECLARE @EmployeeCode NVARCHAR(20), @BirthDate VARCHAR(20), @LastName NVARCHAR(100), @FirstName NVARCHAR(100), @strCmp NVARCHAR(250), @GroupSalCode NVARCHAR(20)
	 SELECT @EmployeeCode = CodeValue FROM #lstOfField WHERE FieldName = N'EmployeeCode'
	 SELECT @BirthDate = CodeValue FROM #lstOfField WHERE FieldName = N'Birthday'
	 SELECT @LastName = CodeValue FROM #lstOfField WHERE FieldName = 'LastName'      
	 SELECT @FirstName = CodeValue FROM #lstOfField WHERE FieldName = 'FirstName' 
	 SELECT @BirthDate = dbo.HR_FNGetRigthBirthday(ISNULL(@BirthDate,''))

	  DECLARE @JoinDateEmp DATETIME, @ContFrom DATETIME,  @EffectDateB datetime 
	SELECT @JoinDateEmp = JoinedOn FROM dbo.HR_Employees with(nolock) WHERE EmployeeID=@EmployeeCode 

	--IF @TableName = 'HCSEM_EmpAward'
	--BEGIN
	--	IF EXISTS (SELECT TOP(1) 1 from dbo.HCSSYS_SettingsForCustomers where KeyCode='checkConstraintAwardDate' AND Value=1)
	--	BEGIN
	--		UPDATE #lstOfField SET CodeValue = NULL WHERE FieldName = 'AwardDate' AND CodeValue = ''
	--		DECLARE @AwardDate DATETIME, @SignedDate datetime
	--		SELECT @AwardDate = CodeValue FROM #lstOfField WHERE FieldName = 'AwardDate' 
	--		SELECT @SignedDate = CodeValue FROM #lstOfField WHERE FieldName = 'SignedDate' 

	--		IF @AwardDate IS NOT NULL AND @AwardDate < @JoinDateEmp
	--		BEGIN
	--			SELECT @Error = 'msgAwardDateVsJoinDate'
	--			SET @Field = 'AwardDate'  
	--			RETURN 
	--		END
	--		IF @SignedDate IS NOT NULL AND @SignedDate < @JoinDateEmp
	--		BEGIN
	--			SELECT @Error = 'msgsigningdateVsJoinDate'
	--			SET @Field = 'SignedDate'  
	--			RETURN 
	--		END
	--	END
	--	DECLARE  @AmountAward money, @ExceptCodeAward varchar(30),@GenDate datetime, @DowCodeAward varchar(7)
	--	SELECT @AmountAward = CodeValue FROM #lstOfField WHERE FieldName = 'Amount' 
	--	SELECT @ExceptCodeAward = CodeValue FROM #lstOfField WHERE FieldName = 'ExceptCode' 
	--	SELECT @GenDate = CodeValue FROM #lstOfField WHERE FieldName = 'GenDate' 
	--	SELECT @DowCodeAward = CodeValue FROM #lstOfField WHERE FieldName = 'DowCode' 
	--	IF ISNULL(@DowCodeAward,'') <> '' AND ISNULL(@AmountAward,0) > 0  AND ISNULL(@ExceptCodeAward,'') <> '' AND @GenDate IS NOT NULL 
	--	AND [dbo].[HCSSYS_fnCheckLockEmpPayPeriod](@Lang, @EmployeeCode, @DowCodeAward, @ExceptCodeAward, 0) <> ''
	--	begin
	--		SELECT @Error = 'msglockedpayroll'
	--		SET @Field = 'EmployeeCode'  
	--		RETURN 
	--	end
	--END
	--IF @TableName = 'HCSEM_EmpContractAllowance'      
	--BEGIN
	--	Declare @EffectDateA_ContractAllowance datetime, @FromDateContract datetime, @ToDateContract datetime, @ContractID int
	--	SELECT @EffectDateA_ContractAllowance = CodeValue FROM #lstOfField WHERE FieldName = 'EffectDateA'  
		
	--	SELECT @ContractID = CodeValue FROM #lstOfField WHERE FieldName = 'RefID' 
	--	SELECT @FromDateContract = ContFrom, @ToDateContract = ContTo from HCSEM_EmpContract WITH (NOLOCK) where RecID = @ContractID

	--	if @JoinDateEmp > @EffectDateA_ContractAllowance
	--	begin
	--		SELECT @Error = ISNULL(Code,'')  FROM #TEMP WHERE Value = 102
	--		SET @Field = 'EffectDateA'    
	--		RETURN
	--	END
	--	if @FromDateContract > @EffectDateA_ContractAllowance
	--	begin
	--		SELECT @Error = 'EffectDateSmallerThanFromDate'
	--		SET @Field = 'EmployeeCode'  
	--		RETURN 
	--	END
	
	--	if @ToDateContract IS NOT NULL AND @EffectDateA_ContractAllowance > @ToDateContract
	--	begin
	--		SELECT @Error = 'EffectDateBiggerThanToDate'
	--		SET @Field = 'EmployeeCode'  
	--		RETURN 
	--	END
	
	--	DECLARE @AlloGradeCode_ContractAllowance varchar(20),  @IsTransferA_ContractAllowance bit , @DecisionNo_ContractAllowance nvarchar(50), @Res_ContractAllowance nvarchar(250)
	--	SELECT  @AlloGradeCode_ContractAllowance = CodeValue FROM #lstOfField WHERE FieldName = 'AlloGradeCode'  
	--	SELECT  @IsTransferA_ContractAllowance = CodeValue FROM #lstOfField WHERE FieldName = 'IsTransferA'
	--	SELECT  @DecisionNo_ContractAllowance = CodeValue FROM #lstOfField WHERE FieldName = 'DecisionNoA'
	--	EXEC HCSEM_spCheckAllowanceImport_Add @EmployeeCode, @EffectDateA_ContractAllowance, @AlloGradeCode_ContractAllowance, 
	--		@IsTransferA_ContractAllowance, @DecisionNo_ContractAllowance, @TableName,@Res_ContractAllowance OUT
	--	IF ISNULL(@Res_ContractAllowance, '') <> ''
	--	BEGIN 
	--		SELECT @Error = 'ExistedAnotherAllowance'
	--		SET @Field = 'EmployeeCode'  
	--		RETURN 
	--	END
	--END	
	--IF @TableName = 'HCSEM_EmpWorkingAlloGrade'      
	--BEGIN
	--	Declare @EffectDateA_WorkingAlloGrade datetime, @FromDateWorking datetime, @ToDateWorking datetime, @WorkingID int
	--	SELECT @EffectDateA_WorkingAlloGrade = CodeValue FROM #lstOfField WHERE FieldName = 'EffectDateA'  

	--	if @JoinDateEmp > @EffectDateA_WorkingAlloGrade
	--	begin
	--		SELECT @Error = ISNULL(Code,'')  FROM #TEMP WHERE Value = 102
	--		SET @Field = 'EffectDateA'    
	--		RETURN
	--	END
	--	SELECT @WorkingID = CodeValue FROM #lstOfField WHERE FieldName = 'RefID' 
	--	SELECT @FromDateWorking = BeginDate, @ToDateWorking = EndDate from HCSEM_EmpWorking WITH (NOLOCK) where RecID = @WorkingID

	--	if @FromDateWorking > @EffectDateA_WorkingAlloGrade
	--	begin
	--		SELECT @Error = 'EffectDateSmallerThanFromDate'
	--		SET @Field = 'EmployeeCode'  
	--		RETURN 
	--	END
	
	--	if @ToDateWorking IS NOT NULL AND @EffectDateA_WorkingAlloGrade > @ToDateWorking
	--	begin
	--		SELECT @Error = 'EffectDateBiggerThanToDate'
	--		SET @Field = 'EmployeeCode'  
	--		RETURN 
	--	END

	--	DECLARE @AlloGradeCode_WorkingAlloGrade varchar(20),  @IsTransferA_WorkingAlloGrade bit , @DecisionNo_WorkingAlloGrade nvarchar(50), @Res_WorkingAlloGrade nvarchar(250)
	--	SELECT  @AlloGradeCode_WorkingAlloGrade = CodeValue FROM #lstOfField WHERE FieldName = 'AlloGradeCode'  
	--	SELECT  @IsTransferA_WorkingAlloGrade = CodeValue FROM #lstOfField WHERE FieldName = 'IsTransferA'
	--	SELECT  @DecisionNo_WorkingAlloGrade = CodeValue FROM #lstOfField WHERE FieldName = 'DecisionNoA'
	--	EXEC HCSEM_spCheckAllowanceImport_Add @EmployeeCode, @EffectDateA_WorkingAlloGrade, @AlloGradeCode_WorkingAlloGrade, 
	--		@IsTransferA_WorkingAlloGrade, @DecisionNo_WorkingAlloGrade,@TableName, @Res_WorkingAlloGrade OUT
	--	IF ISNULL(@Res_WorkingAlloGrade, '') <> ''
	--	BEGIN 
	--		SELECT @Error = 'ExistedAnotherAllowance'
	--		SET @Field = 'EmployeeCode'  
	--		RETURN 
	--	END
	--END	
	--IF @TableName IN('HCSEM_EmpContractAppendix','HCSEM_VWEmpContract_PLHD')      
	--BEGIN
	--	Declare @EffectDateB_Appendix datetime , @FromDate_Appendix datetime, @ToDate_Appendix datetime, @EffectDate_Appendix datetime
	--	SELECT @EffectDateB_Appendix = CodeValue FROM #lstOfField WHERE FieldName = 'EffectDateB'  
	--	SELECT @EffectDate_Appendix = CodeValue FROM #lstOfField WHERE FieldName = 'EffectDate'  
	--	SELECT @FromDate_Appendix = CodeValue FROM #lstOfField WHERE FieldName = 'ContFrom'  
	--	SELECT @ToDate_Appendix = CodeValue FROM #lstOfField WHERE FieldName = 'ContTo'  

	--	if @JoinDateEmp > @EffectDate_Appendix
	--	begin
	--		SELECT @Error = ISNULL(Code,'')  FROM #TEMP WHERE Value = 102
	--		SET @Field = 'EffectDate'    
	--		RETURN
	--	END

	--	IF @EffectDateB_Appendix IS NOT NULL
	--	BEGIN
	--		if @FromDate_Appendix > @EffectDateB_Appendix
	--		begin
	--			SELECT @Error = 'EffectDateSmallerThanFromDate'
	--			SET @Field = 'EmployeeCode'  
	--			RETURN 
	--		END
	
	--		if @ToDate_Appendix IS NOT NULL AND @EffectDateB_Appendix > @ToDate_Appendix
	--		begin
	--			SELECT @Error = 'EffectDateBiggerThanToDate'
	--			SET @Field = 'EmployeeCode'  
	--			RETURN 
	--		END
	--	END
	--END	

	--IF @TableName = 'HCSEM_EmpContractAppendixAllowance'      
	--BEGIN
	--	Declare @EffectDateA_AppendixAllowance datetime , @FromDateAppendix datetime, @ToDateAppendix datetime, @AppendixID int
	--	SELECT @EffectDateA_AppendixAllowance = CodeValue FROM #lstOfField WHERE FieldName = 'EffectDateA'  

	--	if @JoinDateEmp > @EffectDateA_AppendixAllowance
	--	begin
	--		SELECT @Error = ISNULL(Code,'')  FROM #TEMP WHERE Value = 102
	--		SET @Field = 'EffectDateA'    
	--		RETURN
	--	END

	--	SELECT @AppendixID = CodeValue FROM #lstOfField WHERE FieldName = 'RefID' 
	--	SELECT @FromDateAppendix = ContFrom, @ToDateAppendix = ContTo from HCSEM_EmpContractAppendix WITH (NOLOCK) where RecID = @AppendixID

	--	if @FromDateAppendix > @EffectDateA_AppendixAllowance
	--	begin
	--		SELECT @Error = 'EffectDateSmallerThanFromDate'
	--		SET @Field = 'EmployeeCode'  
	--		RETURN 
	--	END
	
	--	if @ToDateAppendix IS NOT NULL AND @EffectDateA_AppendixAllowance > @ToDateAppendix
	--	begin
	--		SELECT @Error = 'EffectDateBiggerThanToDate'
	--		SET @Field = 'EmployeeCode'  
	--		RETURN 
	--	END

	--	DECLARE @AlloGradeCode_AppendixAllowance varchar(20),  @IsTransferA_AppendixAllowance bit , @DecisionNo_AppendixAllowance nvarchar(50), @Res_AppendixAllowance nvarchar(250)
	--	SELECT  @AlloGradeCode_AppendixAllowance = CodeValue FROM #lstOfField WHERE FieldName = 'AlloGradeCode'  
	--	SELECT  @IsTransferA_AppendixAllowance = CodeValue FROM #lstOfField WHERE FieldName = 'IsTransferA'
	--	SELECT  @DecisionNo_AppendixAllowance = CodeValue FROM #lstOfField WHERE FieldName = 'DecisionNoA'
	--	EXEC HCSEM_spCheckAllowanceImport_Add @EmployeeCode, @EffectDateA_AppendixAllowance, @AlloGradeCode_AppendixAllowance, 
	--		@IsTransferA_AppendixAllowance, @DecisionNo_AppendixAllowance,@TableName, @Res_AppendixAllowance OUT
	--	IF ISNULL(@Res_AppendixAllowance, '') <> ''
	--	BEGIN 
	--		SELECT @Error = 'ExistedAnotherAllowance'
	--		SET @Field = 'EmployeeCode'  
	--		RETURN 
	--	END
	--END	
	--IF @TableName = 'HCSEM_EmpDiscipline'      
	--BEGIN 
	--		DECLARE @EmpDiscipline_JoinedDate datetime
	--		DECLARE @EmpDiscipline_DecisionDate datetime
	--		DECLARE @EmpDiscipline_EmployeeCode varchar(20)  
	--		DECLARE @EmpDiscipline_FromTime datetime 

	--		SELECT @EmpDiscipline_EmployeeCode = CodeValue FROM #lstOfField WHERE FieldName = N'EmployeeCode'
	--		SELECT @EmpDiscipline_DecisionDate = CodeValue FROM #lstOfField WHERE FieldName = N'DecisionDate'
	--		SELECT @EmpDiscipline_FromTime = CodeValue FROM #lstOfField WHERE FieldName = N'FromTime'

	--		select top(1) @EmpDiscipline_JoinedDate = JoinDate from HCSEM_Employees WHERE EmployeeCode = @EmpDiscipline_EmployeeCode
			
	--		IF (@EmpDiscipline_DecisionDate < @EmpDiscipline_JoinedDate)            
	--		BEGIN      
	--			SELECT @Error = N'msgdecisionDatelowerthanjoineddate'
	--			SET @Field = 'DecisionDate'  
	--			RETURN  
	--		END      
	--		IF (@EmpDiscipline_FromTime < @EmpDiscipline_JoinedDate)            
	--		BEGIN      
	--			SELECT @Error = N'msgfromdateVsJoinDate'
	--			SET @Field = 'FromTime'  
	--			RETURN  
	--		END      
	--	DECLARE  @AmountDiscipline money, @ExceptCodeDiscipline varchar(30),@GenDateDiscipline datetime, @DowCodeDiscipline varchar(7)
	--	SELECT @AmountDiscipline = CodeValue FROM #lstOfField WHERE FieldName = 'AmountSub' 
	--	SELECT @ExceptCodeDiscipline = CodeValue FROM #lstOfField WHERE FieldName = 'ExceptCode' 
	--	SELECT @GenDateDiscipline = CodeValue FROM #lstOfField WHERE FieldName = 'GenDate' 
	--	SELECT @DowCodeDiscipline = CodeValue FROM #lstOfField WHERE FieldName = 'MonthSub' 

	--	IF ISNULL(@DowCodeDiscipline,'') <> '' AND ISNULL(@AmountDiscipline,0) > 0  AND ISNULL(@ExceptCodeDiscipline,'') <> '' AND @GenDateDiscipline IS NOT NULL 
	--	AND [dbo].[HCSSYS_fnCheckLockEmpPayPeriod](@Lang, @EmployeeCode, @DowCodeDiscipline, @ExceptCodeDiscipline, 0) <> ''
	--	begin
	--		SELECT @Error = 'msglockedpayroll'
	--		SET @Field = 'EmployeeCode'  
	--		RETURN 
	--	end
	-- END 

	 IF @EmployeeCode LIKE N'%''%'
	 BEGIN
		SELECT @Error = 'msgSyntaxEmpCode'
		SET @Field = 'EmployeeCode'  
		RETURN
	 END 
	 SET @LastName = ISNULL(@LastName,'')
	 SET @FirstName = ISNULL(@FirstName,'')

	CREATE TABLE #PhanQuyenNhomLuong(GroupSalCode NVARCHAR(20))

	--IF @TableName = 'HCSTS_EmpTimeOffFundAdj'
	--BEGIN
	--	SELECT @WorkDate = CodeValue FROM #lstOfField WHERE FieldName = 'WorkDate'    
	--	IF ISNULL(@WorkDate,'') = ''
	--	BEGIN
	--		SELECT @Error = 'msgWDempty'
	--		SET @Field = 'WorkDate'  
	--		RETURN
	--	END

	--	DECLARE @NumDayAdj NVARCHAR(20)
	--	SELECT @NumDayAdj = CodeValue FROM #lstOfField WHERE FieldName = 'NumDayAdj'    
	--	IF ISNULL(@WorkDate,'') <> '' and (ISNUMERIC(@NumDayAdj) = 0 OR @NumDayAdj = '' OR @NumDayAdj = NULL) 
	--	BEGIN
	--		SELECT @Error = 'msgNumDayAdjempty'
	--		SET @Field = 'NumDayAdj'  
	--		RETURN
	--	END
	--END
	--IF @TableName = 'HCSEM_EmpInsuranceOther'
	--BEGIN
	--	--EmployeeCode,TypeInsCode,FromDate,FamilyID

	--	DECLARE @TypeInsCode nvarchar(20),@FamilyID int, @SICode nvarchar(20), @SIOtherCode nvarchar(20)

	--	SELECT @TypeInsCode = CodeValue FROM #lstOfField WHERE FieldName = N'TypeInsCode'
	--	SELECT @FromDate = CodeValue FROM #lstOfField WHERE FieldName = N'FromDate '
	--	SELECT @FamilyID = CodeValue FROM #lstOfField WHERE FieldName = N'FamilyID'
	--	SELECT @SICode = CodeValue FROM #lstOfField WHERE FieldName = N'TypeInsCode '
	--	SELECT @SIOtherCode = CodeValue FROM #lstOfField WHERE FieldName = N'SIOtherCode'

	--	IF  EXISTS (select 1 from HCSEM_EmpInsuranceOther where EmployeeCode =@EmployeeCode AND TypeInsCode = @TypeInsCode AND FamilyID =@FamilyID AND FromDate = @FromDate)
	--	BEGIN
	--			SELECT @Error = N'msgdupotherinsure'
	--			SET @Field = 'EmployeeCode'  
	--			RETURN
	--	END

	--	EXEC [HCSEM_SPEmpFamily_InsuranceTypeOther_ByCondition_Import]  @EmployeeCode, @SICode, @SIOtherCode, @UserID, @FromDate

	--	IF @FamilyID Is not null AND NOT EXISTS (SELECT 1 from HCSEM_Family_Condition_Import with(nolock) where UserID = @UserID AND FamilyID = @FamilyID)
	--	BEGIN
	--			SELECT @Error = N'msgthannhankohople'
	--			SET @Field = 'EmployeeCode'  
	--			RETURN
	--	END
	--END
	
	--IF @TableName = 'HCSEM_EmpInsurance'
	--BEGIN
	--	DECLARE @FromMonthBH varchar(10)
	--	DECLARE @ToMonthBH varchar(10)
	--	DECLARE @RecIDBH varchar(10)
	--	SELECT @FromMonthBH = CodeValue FROM #lstOfField WHERE FieldName = N'FromMonth'
	--	SELECT @ToMonthBH = CodeValue FROM #lstOfField WHERE FieldName = N'ToMonth'
	--	SELECT @RecIDBH = CodeValue FROM #lstOfField WHERE FieldName = N'RecID'

	--	IF  EXISTS (select 1 from HCSEM_EmpInsurance where EmployeeCode = @EmployeeCode AND @FromMonthBH >= FromMonth AND @FromMonthBH <= ToMonth and @RecIDBH <> RecID)
	--	BEGIN

	--			SELECT @Error = N'msgdupotherinsure'
	--			SET @Field = 'EmployeeCode'  
	--			RETURN
	--	END
	--	IF  EXISTS (select 1 from HCSEM_EmpInsurance where EmployeeCode = @EmployeeCode AND @ToMonthBH >= FromMonth AND @ToMonthBH <= ToMonth and @RecIDBH <> RecID)
	--	BEGIN
	--			SELECT @Error = N'msgdupotherinsure'
	--			SET @Field = 'EmployeeCode'  
	--			RETURN
	--	END
	--	IF  EXISTS (select 1 from HCSEM_EmpInsurance where EmployeeCode = @EmployeeCode AND @FromMonthBH < FromMonth AND @ToMonthBH > ToMonth and @RecIDBH <> RecID)
	--	BEGIN
	--			SELECT @Error = N'msgdupotherinsure'
	--			SET @Field = 'EmployeeCode'  
	--			RETURN
	--	END
	--END
	--IF @TableName = 'HCSSYS_ConfigTSEmp_VacationDetail'
	--BEGIN
	--	--EmployeeCode,TypeInsCode,FromDate,FamilyID

	--	DECLARE @HCSSYS_ConfigTSEmp_VacationDetail_DateID datetime, @HCSSYS_ConfigTSEmp_VacationDetail_JoinDate datetime, @HCSSYS_ConfigTSEmp_VacationDetail_EndDate datetime

	--	SELECT @HCSSYS_ConfigTSEmp_VacationDetail_DateID = CodeValue FROM #lstOfField WHERE FieldName = N'DateID'
	--	--SELECT @FromDate = CodeValue FROM #lstOfField WHERE FieldName = N'FromDate '
	--	--SELECT @FamilyID = CodeValue FROM #lstOfField WHERE FieldName = N'FamilyID'
	--	--SELECT @SICode = CodeValue FROM #lstOfField WHERE FieldName = N'TypeInsCode '
	--	--SELECT @SIOtherCode = CodeValue FROM #lstOfField WHERE FieldName = N'SIOtherCode'

	--	SELECT @HCSSYS_ConfigTSEmp_VacationDetail_JoinDate  = E.JoinDate, @HCSSYS_ConfigTSEmp_VacationDetail_EndDate = E.EndDate
	--	FROM HCSEM_view_employeeinfo E
	--	WHERE EmployeeCode = @EmployeeCode
	
		
	--	IF   (@HCSSYS_ConfigTSEmp_VacationDetail_DateID > @HCSSYS_ConfigTSEmp_VacationDetail_EndDate)
	--	BEGIN
	--			SELECT @Error = N'msgdupotherinsureVacationDetailtrehon'
	--			SET @Field = 'EmployeeCode'  
	--			RETURN
	--	END

	--	IF   (@HCSSYS_ConfigTSEmp_VacationDetail_DateID < @HCSSYS_ConfigTSEmp_VacationDetail_JoinDate)
	--	BEGIN
	--			SELECT @Error = N'msgdupotherinsureVacationDetailsomhon'
	--			SET @Field = 'EmployeeCode'  
	--			RETURN
	--	END
	
	--END
	--IF @TableName = 'HCSSI_SocialIns'
	--BEGIn
	--	SET @DowCode = ''
	--	SELECT @DowCode = CodeValue FROM #lstOfField WHERE FieldName = 'DowCode'

	--	-- Danh sách phòng ban đã bị khóa
	--	select ce.* into #Deps from (
	--		select DepartmentCode from HCSSYS_fnGetUserLockPayroll_Salary(@DowCode)
	--	) as ce	
		
	--	-- Danh sách NV nằm trong Phòng ban bị khóa
	--	IF EXISTS (SELECT 1 from dbo.HCSEM_Employees as E with (nolock) INNER JOIN #Deps deps on deps.DepartmentCode = E.DepartmentCode AND E.EmployeeCode  = @EmployeeCode)
	--	BEGIN
	--		SELECT @Error = N'lockdow'
	--		SET @Field = 'EmployeeCode'  
	--		RETURN  
	--	END
	--END
	--IF @TableName = 'HCSPR_PayTExcept_Lock_Tmp'
	--BEGIn
	--	SET @DowCode = ''
	--	SELECT @DowCode = CodeValue FROM #lstOfField WHERE FieldName = 'DowCode'
	--	DECLARE @ExceptCode_PayTExcept varchar(20)
	--	SELECT @ExceptCode_PayTExcept = CodeValue FROM #lstOfField WHERE FieldName = 'ExceptCode '
	--	-- Danh sách phòng ban đã bị khóa
	--	select ce.* into #DepsExcept from (
	--		select DepartmentCode from [HCSSYS_fnGetUserLockPayroll](@DowCode,'HCSPR_PayTExcept', @ExceptCode_PayTExcept)
	--	) as ce	
		
	--	-- Danh sách NV nằm trong Phòng ban bị khóa
	--	IF EXISTS (SELECT 1 from dbo.HCSEM_Employees as E with (nolock) INNER JOIN #DepsExcept deps on deps.DepartmentCode = E.DepartmentCode AND E.EmployeeCode  = @EmployeeCode)
	--	BEGIN
	--		SELECT @Error = N'lockdow'
	--		SET @Field = 'EmployeeCode'  
	--		RETURN  
	--	END
	--END
	--IF @TableName = 'HCSEM_EmpAltShift'
	--BEGIn
	--	Declare @IsAltShift bit, @ShiftCode varchar(20), @EffectDateShift datetime, @EndDateShift datetime
		
	--	SELECT @IsAltShift = CodeValue FROM #lstOfField WHERE FieldName = 'IsAltShift'
	--	SELECT @ShiftCode = CodeValue FROM #lstOfField WHERE FieldName = 'ShiftCode'
	--	SELECT @EffectDateShift = CodeValue FROM #lstOfField WHERE FieldName = 'EffectDate'
	--	SELECT @EndDateShift = CodeValue FROM #lstOfField WHERE FieldName = 'EndDate'
	--	-- Danh sách phòng ban đã bị khóa
	--	IF @IsAltShift = 1 AND ISNULL(@ShiftCode,'') <> ''
	--	BEGIN
	--		-- ca thay đổi - ko chọn ca làm việc
	--		SELECT @Error = N'HaveNoShift'
	--		SET @Field = 'ShiftCode'  
	--		RETURN  
	--	END
	--	ELSE IF  @IsAltShift = 0 AND ISNULL(@ShiftCode,'') = ''
	--	BEGIN
	--		-- ca cố dịnh => chọn ca
	--		SELECT @Error = N'HaveShift'
	--		SET @Field = 'ShiftCode'  
	--		RETURN  
	--	END
	--	ELSE IF EXISTS (SELECT 1 from HCSEM_EmpAltShift where 
	--					EmployeeCode = @EmployeeCode AND EffectDate <> @EffectDateShift and
	--					((@EffectDateShift >= EffectDate AND @EffectDateShift <= EndDate)
	--					OR  (@EndDateShift IS NOT NULL AND @EndDateShift >= EffectDate AND @EndDateShift <= EndDate)
	--					OR  (@EndDateShift <= EffectDate AND (@EndDateShift IS NOT NULL AND @EndDateShift >= EndDate)))
	--	)
	--	BEGIN
	--		-- Thời gian bi lồng nhau
	--		SELECT @Error = N'timenested'
	--		SET @Field = 'EffectDate'  
	--		RETURN  
	--	END
	--END
	--IF @TableName = 'HCSEM_EmpBank'      
	--BEGIN 
	--		DECLARE @AccountNo VARCHAR(10)      
	--		DECLARE @RecIDEmpBank VARCHAR(10)      
	--		SELECT @AccountNo = CodeValue FROM #lstOfField WHERE FieldName = 'AccountNo'
	--		SELECT @RecIDEmpBank = CodeValue FROM #lstOfField WHERE FieldName = 'RecID'
	--		IF EXISTS (SELECT 1 FROM [hcsem_fncheckDuplicateAccount](@RecIDEmpBank, @AccountNo, @EmployeeCode, @Lang))            
	--		BEGIN      
	--			SELECT @Error = N'msgempbankduplicated'
	--			SET @Field = 'AccountNo'  
	--			RETURN  
	--		END      
	-- END 

	--IF @TableName = N'HCSEM_EmpInfoForeigner'
	--BEGIN
	--    DECLARE @Foreigner BIT
 --       SELECT @Foreigner = CodeValue FROM #lstOfField WHERE FieldName = 'Foreigner' 
	--	IF ISNULL(@Foreigner,0) = 0
	--	BEGIN
	--		IF EXISTS (SELECT 1 FROM #lstOfField WHERE FieldName = 'FoPermiss' AND ISNULL(CodeValue,'') <> '')
	--			OR EXISTS (SELECT 1 FROM #lstOfField WHERE FieldName = 'FoBeginDate' AND ISNULL(CodeValue,'') <> '')
	--			OR EXISTS (SELECT 1 FROM #lstOfField WHERE FieldName = 'FoEndDate' AND ISNULL(CodeValue,'') <> '')
	--			OR EXISTS (SELECT 1 FROM #lstOfField WHERE FieldName = 'FoExtTime' AND ISNULL(CodeValue,'') <> '')
	--		BEGIN
	--			SELECT @Error = 'msgLDNN001'
	--			--SET @Field = 'EmployeeCode'  
	--			SELECT TOP(1) @Field = FieldName FROM #lstOfField WHERE (FieldName = 'FoPermiss' AND ISNULL(CodeValue,'') <> '') OR 
	--											(FieldName = 'FoBeginDate' AND ISNULL(CodeValue,'') <> '') OR
	--											(FieldName = 'FoEndDate' AND ISNULL(CodeValue,'') <> '') OR
	--											(FieldName = 'FoExtTime' AND ISNULL(CodeValue,'') <> '')
	--			IF(ISNULL(@Field,'') = '') SET @Field = 'EmployeeCode'
	--			RETURN
	--		END
	--	END
	--END
	---- TAI NAN LAO DONG
	--IF @TableName = 'HCSEM_EmpAccident'
	--BEGIN
	--	DECLARE @HCSEM_EmpAccident_OccurDate datetime
	--	DECLARE @HCSEM_EmpAccident_SubsidiseDate datetime
	--	DECLARE @HCSEM_EmpAccident_FromTime datetime
	--	DECLARE @HCSEM_EmpAccident_ToTime datetime
	--	DECLARE @HCSEM_EmpAccident_IssuedDate datetime
	--	DECLARE @HCSEM_EmpAccident_EmployeeCode varchar(20)
	--	DECLARE @HCSEM_EmpAccident_EmpJoinedDate datetime
	--	DECLARE @HCSEM_EmpAccident_EmpDetectiveDate datetime
		

	--	SELECT @HCSEM_EmpAccident_OccurDate = CodeValue FROM #lstOfField WHERE FieldName = N'OccurDate'
	--	SELECT @HCSEM_EmpAccident_SubsidiseDate = CodeValue FROM #lstOfField WHERE FieldName = N'SubsidiseDate'
	--	SELECT @HCSEM_EmpAccident_ToTime = CodeValue FROM #lstOfField WHERE FieldName = N'ToTime'
	--	SELECT @HCSEM_EmpAccident_FromTime = CodeValue FROM #lstOfField WHERE FieldName = N'FromTime'
	--	SELECT @HCSEM_EmpAccident_IssuedDate = CodeValue FROM #lstOfField WHERE FieldName = N'IssuedDate'
	--	SELECT @HCSEM_EmpAccident_EmployeeCode = CodeValue FROM #lstOfField WHERE FieldName = N'EmployeeCode'
	--	SELECT @HCSEM_EmpAccident_EmpDetectiveDate = CodeValue FROM #lstOfField WHERE FieldName = N'DetectDate'
	--	SELECT @HCSEM_EmpAccident_EmpJoinedDate = JoinDate FROM HCSEM_Employees where EmployeeCode = @HCSEM_EmpAccident_EmployeeCode


	

	--	IF  (@HCSEM_EmpAccident_FromTime > @HCSEM_EmpAccident_ToTime)
	--	BEGIN

	--			SELECT @Error = N'msgfromtimetotime'
	--			SET @Field = 'FromTime'  
	--			RETURN
	--	END
	--	IF  (@HCSEM_EmpAccident_IssuedDate < @HCSEM_EmpAccident_OccurDate)
	--	BEGIN

	--			SELECT @Error = N'msgngaycaplonhonngayxayra'
	--			SET @Field = 'IssuedDate'  
	--			RETURN
	--	END
	--	IF  (@HCSEM_EmpAccident_SubsidiseDate < @HCSEM_EmpAccident_OccurDate)
	--	BEGIN

	--			SELECT @Error = N'msgsophucapngaylonhonngayxayra'
	--			SET @Field = 'SubsidiseDate'  
	--			RETURN
	--	END
	--	IF  (@HCSEM_EmpAccident_FromTime < @HCSEM_EmpAccident_OccurDate)
	--	BEGIN

	--			SELECT @Error = N'msgnghitungaylonhonngayxayra'
	--			SET @Field = 'FromTime'  
	--			RETURN
	--	END
	--	IF  (@HCSEM_EmpAccident_OccurDate < @HCSEM_EmpAccident_EmpJoinedDate)
	--	BEGIN

	--			SELECT @Error = N'msgowrongoccurdate'
	--			SET @Field = 'OccurDate'  
	--			RETURN
	--	END
	--	IF  (@HCSEM_EmpAccident_IssuedDate < @HCSEM_EmpAccident_EmpJoinedDate)
	--	BEGIN

	--			SELECT @Error = N'msgowrongissueddate'
	--			SET @Field = 'IssuedDate'  
	--			RETURN
	--	END
	--	IF  (@HCSEM_EmpAccident_SubsidiseDate < @HCSEM_EmpAccident_EmpJoinedDate)
	--	BEGIN

	--			SELECT @Error = N'msgsubsidisedate'
	--			SET @Field = 'SubsidiseDate'  
	--			RETURN
	--	END
	--	IF  (@HCSEM_EmpAccident_FromTime < @HCSEM_EmpAccident_EmpJoinedDate)
	--	BEGIN

	--			SELECT @Error = N'msgfromtime'
	--			SET @Field = 'FromTime'  
	--			RETURN
	--	END
	--	IF  (@HCSEM_EmpAccident_ToTime < @HCSEM_EmpAccident_EmpJoinedDate)
	--	BEGIN

	--			SELECT @Error = N'msgtotime'
	--			SET @Field = 'ToTime'  
	--			RETURN
	--	END
	--	IF  (@HCSEM_EmpAccident_EmpDetectiveDate < @HCSEM_EmpAccident_EmpJoinedDate)
	--	BEGIN

	--			SELECT @Error = N'msgDetectDate'
	--			SET @Field = 'DetectDate'  
	--			RETURN
	--	END
	--END
	--IF @TableName = 'HCSEM_EmpInfoGroupSalary'
	--BEGIN
	--	INSERT INTO #PhanQuyenNhomLuong(GroupSalCode)
	--	select GroupSalCode from HCSSYS_fnPhanQuyenNhomLuong_WithEmp(@UserID,'HCSHREMP01.PL.NTL')

	--	--SELECT * FROM #PhanQuyenNhomLuong
	--	IF EXISTS (select 1 from #PhanQuyenNhomLuong)
	--	BEGIN
	--		--SELECT @GroupSalCode = CodeValue FROM #lstOfField WHERE FieldName = N'GroupSalCode'
	--		--SELECT @EmployeeCode AS '@EmployeeCode'
	--		SELECT @GroupSalCode = GroupSalCode FROM dbo.HCSEM_EmpInfoGroupSalary WITH(NOLOCK) WHERE EmployeeCode = @EmployeeCode
	--		IF ISNULL(@GroupSalCode,'') <> ''
	--			AND NOT EXISTS (SELECT 1 FROM #PhanQuyenNhomLuong WHERE GroupSalCode = @GroupSalCode)
	--		BEGIN
	--			SELECT @Error = 'msgNTL001'
	--			SET @Field = 'GroupSalCode'  
	--			RETURN
	--		END
	--	END
	--END
	 
	 SET @strCmp = ISNULL(@BirthDate+@LastName + N' ' + @FirstName,'')
	 --select @LastName,@FirstName,@strCmp as '@strCmp'

	 --select @BirthDate
	 if isnull(@BirthDate,'') <> ''
	 begin
		if dbo.HCSSYS_FNCheckBirthday(@BirthDate) = 0
		begin
			SELECT @Error = N'birthdatenotcorrectformat'
			SET @Field = 'Birthday'  
			RETURN
		END
	 END
	 --IF @TableName='HCSEM_EmpTrainCourse_Cost'
	 --BEGIN
		--DECLARE @TrainCourseCode nvarchar(20)
		--SELECT @TrainCourseCode = CodeValue FROM #lstOfField WHERE FieldName = N'TrainCourseCode'
		--IF NOT EXISTS (select top(1) 1 from HCSEM_EmpTrainCourse where EmployeeCode =@EmployeeCode AND TrainCourseCode = @TrainCourseCode)
		--BEGIN
		--		SELECT @Error = N'MSgNoCourse'
		--		SET @Field = 'TrainCourseCode'  
		--		RETURN
		--END
	 --END
	 --IF @TableName = 'HCSEM_EmpResearch'
	 --BEGIN
		--SELECT @FromDate = CodeValue FROM #lstOfField WHERE FieldName = N'FromDate'
		--SELECT @ToDate = CodeValue FROM #lstOfField WHERE FieldName = N'ToDate'

		--IF @FromDate IS NOT NULL AND @ToDate IS NOT NULL
		--BEGIN
		--	IF @FromDate > @ToDate
		--	BEGIN
		--		SELECT @Error = N'MsgRegisterLateEarly_Uivalidate001'
		--		SET @Field = 'FromDate'  
		--		RETURN
		--	END
		--END
		--DECLARE @ResearchCode NVARCHAR(200), @ResearchName NVARCHAR(200), @Year NVARCHAR(10)
		--SELECT @ResearchCode = CodeValue FROM #lstOfField WHERE FieldName = N'ResearchCode'
		--SELECT @ResearchName = CodeValue FROM #lstOfField WHERE FieldName = N'ResearchName'
		--SELECT @Year = CodeValue FROM #lstOfField WHERE FieldName = N'Year'
		--IF RTRIM(ISNULL(@ResearchCode,'')) = ''
		--BEGIN
		--	SELECT @Error = N'MsgSys0007'
		--	SET @Field = 'ResearchCode'  
		--	RETURN
		--END
		--IF RTRIM(ISNULL(@ResearchName,'')) = ''
		--BEGIN
		--	SELECT @Error = N'MsgSys0008'
		--	SET @Field = 'ResearchName'  
		--	RETURN
		--END
		--IF ISDATE(@Year + '/01/01') = 0
		--BEGIN
		--	SELECT @Error = N'MsgSys0009'
		--	SET @Field = 'Year'  
		--	RETURN
		--END
	 --END

	
	 --IF @TableName = 'HCSHP_RemoteWorkingRequest_tmp'
	 --BEGIN
		----IF ISNULL(@EmployeeCode,'') = '' OR NOT EXISTS (SELECT 1 FROM dbo.HCSSYS_FNGetListEmployeeForManagerCode(@UserID,@UserCode,1,1,1,-1) WHERE EmployeeCode = @EmployeeCode)
		----BEGIN
		----	--Mã nhân viên không thuộc quyền quản lý của bạn
		----	SELECT @Error = N'MsgSys0005'
		----	SET @Field = 'EmployeeCode'  
		----	RETURN
		----END
		--DECLARE @Typeofwork NVARCHAR(20)
		--SELECT @Typeofwork = CodeValue FROM #lstOfField WHERE FieldName = N'Typeofwork'
		--IF ISNULL(@Typeofwork,'') = '' OR NOT EXISTS (SELECT 1 FROM dbo.HCS_Fn_GetValueList('VN','HCSHP_RemoteWorkingRequest.Typeofwork') WHERE Value = @Typeofwork)
		--BEGIN
		--	SELECT @Error = N'Chưa chọn loại công việc'
		--	SET @Field = 'Typeofwork'  
		--	RETURN
		--END
		--DECLARE @Time NVARCHAR(20)
		--SELECT @Time = CodeValue FROM #lstOfField WHERE FieldName = N'Time'
		--IF ISNULL(@Time,'') = '' OR NOT EXISTS (SELECT 1 FROM dbo.HCS_Fn_GetValueList('VN','HCSHP_RemoteWorkingRequest.Time') WHERE Value = @Time)
		--BEGIN
		--	SELECT @Error = N'Chưa chọn buổi'
		--	SET @Field = 'Time'  
		--	RETURN
		--END
		--SET @FromDate  = NULL
		--SELECT @FromDate = CodeValue FROM #lstOfField WHERE FieldName = N'FromDate'
		--IF @FromDate IS NULL
		--BEGIN
		--	SELECT @Error = N'Chưa chọn ngày'
		--	SET @Field = 'FromDate'  
		--	RETURN
		--END
		--RETURN
	 --END
	 --IF @TableName = 'HCSHP_PhanCaRequestTmp'
	 --BEGIN
		--IF EXISTS (SELECT top(1) 1 From #lstOfField A LEFT JOIN HCSLS_Shift B WITH (nolock) on A.CodeValue = B.ShiftCode
		--			where A.FieldName LIKE N'Shift_Code%' and B.ShiftCode is null)
		--begin
		--	SELECT @Error = N'shiftnotfound'
		--	SET @Field = 'EmployeeCode'  
		--	RETURN
		--end
	 --END
	 IF ISNULL(@EmployeeCode,'') <> '' 
		AND @TableName NOT IN ('HCSEM_VWEmployeeTemplate','TASAT_Applicants', 'TASOB_Employees','HCSSYS_DomainRolesUsers_tmp')
	 BEGIN
		IF @TableName = 'HCSHP_PhanCaRequestTmp' OR @TableName = 'HCSEM_EmpTaskDaily_RegTmp' OR @TableName ='HCSHP_EmpProcessValidTime_Tmp'
					OR @TableName ='HCSHP_OTRequestDetail_tmp'
		BEGIN
			IF NOT EXISTS (SELECT 1 FROM dbo.HCSSYS_FNGetListEmployeeForManagerCode(@UserID,@UserCode,1,1,1,-1) WHERE EmployeeCode = @EmployeeCode)
			BEGIN
				--Mã nhân viên không thuộc quyền quản lý của bạn
				SELECT @Error = N'MsgSys0005'
				SET @Field = 'EmployeeCode'  
				RETURN
			END
		END
		ELSE
		BEGIN
			IF exists (select 1 from HCSEM_Employees where EmployeeCode=@EmployeeCode) and
				NOT EXISTS (SELECT 1 FROM dbo.HCS_HR_Fn_GetEmployeeByUserID_F2(@UserID) WHERE EmployeeCode = ISNULL(@EmployeeCode,''))
			BEGIN
				--Mã nhân viên không thuộc quyền quản lý của bạn
				SELECT @Error = N'MsgSys0005'
				SET @Field = 'EmployeeCode'  
				RETURN
			END
		END
	END

	 --IF @TableName LIKE 'HCSTS_RegisterDayOff%'
	 --BEGIN
		--SELECT @EmpCode = CodeValue FROM #lstOfField WHERE FieldName = 'EmployeeCode'
		--SELECT @DowCode = CodeValue FROM #lstOfField WHERE FieldName = 'DowCode'

		--declare curtgC cursor for
		--	SELECT REPLACE(FieldName,'Code','') AS dd FROM #lstOfField WHERE ISNULL(FieldName,'') <> '' AND FieldName LIKE 'Code%'
		--open curtgC
		--fetch next from curtgC into @Code
		--while @@FETCH_STATUS=0
		--begin
			
		--	SET @dddd = @DowCode + '/' + @Code
		--	IF ISDATE(@dddd) = 1
		--	BEGIN
		--		IF EXISTS (SELECT 1  FROM HCSTS_fnCheckLockDataTimeSheet_WithEmp(@EmpCode, NULL, @dddd, @dddd, NULL))
		--		BEGIN
		--			INSERT INTO HCSTS_RegisterDayOff_err_tmp(UserID,EmployeeCode,WorkDate,Note)
		--			VALUES(@UserID, @EmpCode, @dddd,N'Ngày nghỉ thuộc ngày khóa bảng công')
		--		END
		--	END
		--	fetch next from curtgC into @Code
		--end
		--close curtgC
		--deallocate curtgC
	 --END

	 DECLARE @RecID BIGINT
	 --import nghi bu-HSNV
	 DECLARE @BegDate DATETIME, @EndDate DATETIME,@KowCode NVARCHAR(20), @LeavePeriod NVARCHAR(2), @dd NVARCHAR(50), @FromTime NVARCHAR(8), @ToTime NVARCHAR(8)  
	 --IF @TableName = N'HCSEM_VWEmpDayOff_NB'
	 --BEGIN
		--	SET @dd = NULL
		--	SELECT @dd = CodeValue FROM #lstOfField WHERE FieldName = N'BeginDate'
		--	IF(ISDATE(ISNULL(@dd,''))<>1)
		--	BEGIN
		--		SELECT @Error = N'msgshift003'
		--		SET @Field = 'BeginDate'    
		--		RETURN
		--	END
		--	SET @BegDate = @dd

		--	SET @dd = NULL
		--	SELECT @dd = CodeValue FROM #lstOfField WHERE FieldName = N'EndDate'
		--	IF(ISDATE(ISNULL(@dd,''))<>1)
		--	BEGIN
		--		SELECT @Error = N'msgshift003'
		--		SET @Field = 'EndDate'    
		--		RETURN
		--	END
		--	SET @EndDate = @dd

		--	SELECT @KowCode = CodeValue FROM #lstOfField WHERE FieldName = N'KowCode'
		--	IF NOT EXISTS (SELECT 1 FROM dbo.HCSLS_KOW WITH(NOLOCK) WHERE KowCode = ISNULL(@KowCode,'') AND KowType = 16)
		--	BEGIN
		--		--Loại công không đúng
		--		SELECT @Error = N'MsgSys0004'
		--		SET @Field = 'KowCode'    
		--		RETURN
		--	END

		--	SELECT @LeavePeriod = CodeValue FROM #lstOfField WHERE FieldName = N'LeavePeriod'
		--	IF NOT EXISTS (SELECT 1 FROM dbo.HCS_Fn_GetValueList('VN','HCSEM_EmpDayOff.LeavePeriod') WHERE Value = ISNULL(@LeavePeriod,''))
		--	BEGIN
		--		--Buổi bắt đầu nghỉ không đúng
		--		SELECT @Error = N'MsgSys0006'
		--		SET @Field = 'LeavePeriod'    
		--		RETURN
		--	END

		--	SELECT @Fromtime = CodeValue FROM #lstOfField WHERE FieldName = N'Fromtime'
		--	SELECT @ToTime = CodeValue FROM #lstOfField WHERE FieldName = N'ToTime'

		--	DECLARE @DateNum FLOAT, @LeaveDayNum FLOAT, @HoilydayNum FLOAT, @VacationNum FLOAT,@SundayNum FLOAT, @IsAddNew BIT	
		--	DECLARE @YearNum FLOAT, @Lperiod INT,@CurDay FLOAT,@OldDay FLOAT
		--	SET @DateNum = 0
		--	SET @LeaveDayNum = 0
		--	SET @HoilydayNum = 0
		--	SET @VacationNum = 0
		--	SET @SundayNum = 0
		--	EXEC dbo.HCSTS_spSumDayOffEmp @RecID = @RecID,                         -- bigint
		--							@EmployeeCode = @EmployeeCode,                -- nvarchar(20)
		--							@BeginDate = @BegDate, -- datetime
		--							@EndDate = @EndDate,   -- datetime
		--							@LeavePeriod = @LeavePeriod,                   -- int
		--							@IsSubHoliday = 1,               -- bit
		--							@IsSubWeek = 1,                  -- bit
		--							@IsSunDay = 0,                   -- bit
		--							@IsPhep = 0,                        -- int
		--							@DateNum = @DateNum OUTPUT,         -- float
		--							@HoilydayNum = @HoilydayNum OUTPUT, -- float
		--							@VacationNum = @VacationNum OUTPUT, -- float
		--							@LeaveDayNum = @LeaveDayNum OUTPUT, -- float
		--							@SundayNum = @SundayNum OUTPUT      -- float
		--	DECLARE @DailyTimeNum FLOAT SET @DailyTimeNum = @DateNum * 8.0

		--	IF NOT EXISTS (SELECT 1 FROM HCSEM_EmpDayOff WHERE EmployeeCode = @EmployeeCode AND BeginDate = @BegDate 
		--												AND LeavePeriod=@LeavePeriod AND KowCode = @KowCode)
		--	BEGIN
		--		SET @RecID = 0
		--		SET @IsAddNew = 1
		--	END
		--	ELSE
		--	BEGIN
		--		SET @IsAddNew = 0
		--		SELECT @YearNum = YearNum, @Lperiod = LeavePeriod, @RecID = RecID FROM HCSEM_EmpDayOff WHERE EmployeeCode = @EmployeeCode AND BeginDate = @BegDate 
		--												AND LeavePeriod=@LeavePeriod AND KowCode = @KowCode
		--		--neu co thay doi so ngay phep thi moi validate
		--		IF @YearNum <> @DateNum OR @Lperiod <> @LeavePeriod
		--		BEGIN
		--			PRINT N'validate qũy'
		--		END
		--		ELSE
		--		BEGIN
		--			GOTO NextExistsRow
		--		END
		--	END
		--	EXEC HCSHP_spInfoCheckValidateRegExtraDayOff 
		--										'',@UserID,'HCSHREMP01.QTLV.NB',
		--										@BegDate,
		--										@EndDate,
		--										@KowCode,
		--										@DateNum,
		--										@LeavePeriod,
		--										@DailyTimeNum,   
		--										1, --@IsSubWeek
		--										1, --@IsSubHoliday  
		--										@CurDay,
		--										@OldDay, 
		--										@EmployeeCode ,   
		--										0, --@IsRegNegative
		--										@IsAddNew , --@IsAddNew
		--										1 ,  --@IsIgnoreForetell             
		--										NULL, --@CountErr OUTPUT
		--										0, --@IsPortal
		--										@RecID,
		--										NULL,@Fromtime,@ToTime,
		--										@Error OUTPUT
		--	IF ISNULL(@Error,'') <> '' 
		--	BEGIN
		--		SET @Field = 'EmployeeCode' 
		--		RETURN
		--	END

		--	NextExistsRow:
		--	RETURN
	 --END
    
	--SELECT * FROM #lstOfField      
	--SELECT * FROM HCSSYS_ConfigFieldBU      
   
	 SELECT T.*, S.CodeValue INTO #lstOfData      
	 FROM #lstOfField S      
	 INNER JOIN HCSSYS_ConfigFieldBU T ON T.FieldName = S.FieldName      
	 WHERE T.TableName = @TableName     
      
	DECLARE @IsLoginBU BIT SET @IsLoginBU = 0      
	 IF EXISTS (SELECT 1 from HCSSYS_SettingsForCustomers WHERE KeyCode='isCUSTOMERUsingBU' AND Value=1 )      
	 BEGIN      
		SET @IsLoginBU = 1      
	 END      
-------------------------------------- begin Khóa nhập liệu nhân viên - Khai báo (tvnhuy: 24/12/2020) --------------------------------------
	DECLARE @DepBe NVARCHAR(20)
	DECLARE @DepAf NVARCHAR(20)
	DECLARE @JoinDateBe DATE
	DECLARE @JoinDateAf DATE
	DECLARE @GroupSalCodeBe VARCHAR(20)
	DECLARE @GroupSalCodeAf VARCHAR(20)
	DECLARE @CurrencyCodeBe VARCHAR(10)
	DECLARE @CurrencyCodeAf VARCHAR(10)
	DECLARE @TaxCodeBe VARCHAR(20)
	DECLARE @TaxCodeAf VARCHAR(20)
	DECLARE @SICodeBe VARCHAR(20)
	DECLARE @SICodeAf VARCHAR(20)
	DECLARE @HICodeBe VARCHAR(20)
	DECLARE @HICodeAf VARCHAR(20)
	DECLARE @UICodeBe VARCHAR(20)
	DECLARE @UICodeAf VARCHAR(20)
	DECLARE @EndDateBe DATE
	DECLARE @EndDateAf DATE
	DECLARE @EffectDateBe DATE
	DECLARE @EffectDateAf DATE

	DECLARE @IDLock INT
	DECLARE @IsLock BIT
	DECLARE @Now DATETIME SET @Now = GETDATE()
	
	CREATE TABLE #tmpLock
	(
		FinishDate DATETIME,
		LockDate DATETIME,
		IsLock BIT
	)

	DECLARE @EmpCodeLock NVARCHAR(20)
	SELECT @EmpCodeLock = CodeValue FROM #lstOfField WHERE FieldName = 'EmployeeCode'

-------------------------------------- end Khóa nhập liệu nhân viên - Khai báo (tvnhuy: 24/12/2020) --------------------------------------
      
	--hntruong 11/09/2019      
	--import qua trinh luong co ban, bat validate Khung luong cua THP      
	IF @TableName = 'HCSEM_EmpBasicSalary'      
	BEGIN
-------------------------------------- begin Khóa nhập liệu nhân viên - Lương căn bản (tvnhuy: 24/12/2020) --------------------------------------
	-- Lương cơ bản
	SELECT @EffectDateBe = CONVERT(DATE, EffectDate) FROM HCSEM_EmpBasicSalary WHERE EmployeeCode = @EmpCodeLock
	SELECT @EffectDateAf = CONVERT(DATE, CodeValue) FROM #lstOfField WHERE FieldName = 'EffectDate'  

	if @JoinDateEmp is not null and @EffectDateAf is not null
	begin
		if @EffectDateAf < @JoinDateEmp
		begin
			SELECT @Error = ISNULL(Code,'')  FROM #TEMP WHERE Value = 102
			SET @Field = 'EffectDate'    
			RETURN
		END
	END	

	IF(@EffectDateBe <> @EffectDateAf)
	BEGIN
		SET @IDLock = 101
		DELETE #tmpLock
		INSERT INTO #tmpLock
		EXEC dbo.HCSSYS_SpCheckLockEmpData_Permission @UserID, @IDLock, @EffectDateAf, @EmpCodeLock
		
		SELECT @IsLock = IsLock FROM #tmpLock
		IF(@IsLock = 1)
		BEGIN
			SELECT @Error = ISNULL(Code,'')  FROM #TEMP WHERE Value = 46
			SET @Field = 'EffectDate'    
			RETURN
		END
	END
-------------------------------------- end Khóa nhập liệu nhân viên - Lương căn bản (tvnhuy: 24/12/2020) --------------------------------------

	IF EXISTS (SELECT 1 FROM #lstOfField WHERE FieldName = 'RealSalary')      
	BEGIN      
		DECLARE @RealSalary FLOAT, @ErrorVal int      
		SELECT @RealSalary=CodeValue FROM #lstOfField WHERE FieldName = 'RealSalary'      
		SELECT @ErrorVal = Error FROM dbo.HCSSYS_fnPermissions_AllowSalStatusPosCode_ValidateVuotKhungLuong(@UserID, @EmployeeCode, @RealSalary)      
		IF @ErrorVal = 2      
		BEGIN      
			--SET @Error = N'Mức lương không nằm trong khung lương phân quyền. Nếu tiếp tục thì bạn sẽ không thấy quá trình lương của nhân vien này nửa.'    
			SELECT @Error = ISNULL(Code,'')     
			FROM #TEMP WHERE Value=7    
			SET @Field = 'RealSalary'
			RETURN      
		END      
		ELSE IF @ErrorVal = 1     
		BEGIN      
			--SET @Error = N'Mức lương vượt quá khung lương của chức danh hiện tại.'    
			SELECT @Error = ISNULL(Code,'')     
			FROM #TEMP WHERE Value=8    
			SET @Field = 'RealSalary'
			RETURN      
		END      
		END      
	END
 
	--import kinh nghiem truoc day, tu ngay den ngay - tvnhuy 17/02/2021     
	IF @TableName = 'HCSEM_EmpExperience'
	BEGIN
	
	DECLARE @strDate NVARCHAR(10)
	DECLARE @strDate2 NVARCHAR(10)
	

	SELECT @strDate = CodeValue FROM #lstOfField WHERE FieldName = 'BeginDate'
	SELECT @strDate2 = CodeValue FROM #lstOfField WHERE FieldName = 'EndDate'
	SELECT @RecID = CodeValue FROM #lstOfField WHERE FieldName = 'RecID'

	--Validate ngày lồng nhau - tvnhuy 17/02/2021
	DECLARE @B_DD VARCHAR(2),@B_MM VARCHAR(2), @B_YYYY VARCHAR(4), @E_DD VARCHAR(2),@E_MM VARCHAR(2), @E_YYYY VARCHAR(4)
	DECLARE @nowExp DATE
	DECLARE @Num INT, @BDate_Num INT, @EDate_Num INT
	DECLARE @Bdate DATE
	DECLARE @Edate DATE

	SELECT @BDate_Num = COUNT(1) FROM dbo.HCSSYS_FNSplitString_varchar(@strDate,'/')
	SET @now = CONVERT(DATE, GETDATE(), 105) -- yyyy/MM/dd (105)

	IF(@BDate_Num = 1)
		BEGIN
			SELECT @B_YYYY = data FROM dbo.HCSSYS_FNSplitString_varchar(@strDate,'/') WHERE zeroBasedOccurance = 0
			SET @Bdate = CONVERT(DATE, '01/01/' + @B_YYYY, 105)
		END
	ELSE IF (@BDate_Num = 2)
		BEGIN
			SELECT @B_MM = data FROM dbo.HCSSYS_FNSplitString_varchar(@strDate,'/') WHERE zeroBasedOccurance = 1
			SELECT @B_YYYY = data FROM dbo.HCSSYS_FNSplitString_varchar(@strDate,'/') WHERE zeroBasedOccurance = 0
			SET @Bdate = CONVERT(DATE, '01/' + @B_MM + '/' + @B_YYYY, 105)
		END
	ELSE IF (@BDate_Num = 3)
		BEGIN
			SET @Bdate = cast(convert(varchar(10), @strDate, 111) as datetime)--CONVERT(DATE, @strDate, 105)
		END
    
	IF(ISNULL(@strDate2, '') = '')
		BEGIN
			SET @Edate = NULL -- null được tính là đang làm tới hiện tại
		END
	ELSE
		BEGIN
			SELECT @EDate_Num = COUNT(1) FROM dbo.HCSSYS_FNSplitString_varchar(@strDate2,'/')
			IF(@EDate_Num = 1)
				BEGIN
					SELECT @E_YYYY = data FROM dbo.HCSSYS_FNSplitString_varchar(@strDate2,'/') WHERE zeroBasedOccurance = 0
					SET @Edate = CONVERT(DATE, '31/12/' + @E_YYYY, 105)
				END
			ELSE IF(@EDate_Num = 2)
				BEGIN
					SELECT @E_MM = data FROM dbo.HCSSYS_FNSplitString_varchar(@strDate2,'/') WHERE zeroBasedOccurance = 1
					SELECT @E_YYYY = data FROM dbo.HCSSYS_FNSplitString_varchar(@strDate2,'/') WHERE zeroBasedOccurance = 0
					DECLARE @tmpDate DATE -- lay ngay cuoi thang 
					SET @tmpDate = CONVERT(DATE, '01/' + @E_MM + '/' + @E_YYYY, 105)
					SET @tmpDate =  DATEADD (dd, -1, DATEADD(mm, DATEDIFF(mm, 0, @tmpDate) + 1, 0))
					SET @Edate = CONVERT(DATE, @tmpDate, 105)
				END
			ELSE IF(@EDate_Num = 3)
				BEGIN
					SET @Edate = cast(convert(varchar(10), @strDate2, 111) as datetime)----CONVERT(DATE, @strDate2, 105)
				END 
		END
	;WITH EmpExperience_tmp 
		AS (SELECT RecID, EmployeeCode, CASE WHEN LEN(BeginDate) = 4 THEN cast(convert(varchar(10), BeginDate + '/01/01', 111) as datetime)
											 WHEN LEN(BeginDate) = 7 THEN cast(convert(varchar(10), BeginDate + '/01', 111) as datetime)
											 ELSE cast(convert(varchar(10), BeginDate, 111) as datetime) END AS BeginDate,
											
										CASE WHEN ISNULL(EndDate, '') = '' THEN CONVERT(DATE, GETDATE(), 105)
											 WHEN LEN(EndDate) = 4 THEN cast(convert(varchar(10), BeginDate + '/12/31', 111) as datetime)
											 WHEN LEN(EndDate) = 7 THEN CONVERT(DATE, DATEADD(DAY, -1, DATEADD(MONTH, 1, cast(convert(varchar(10), EndDate+ '/01', 111) as datetime))), 105)
											 ELSE cast(convert(varchar(10), EndDate, 111) as datetime) END AS EndDate
			FROM dbo.HCSEM_EmpExperience
			WHERE EmployeeCode = @EmployeeCode and BeginDate <> isnull(@strDate,'') and EndDate <> isnull(@strDate2,''))
	SELECT @Num = COUNT(1) 
	FROM EmpExperience_tmp AS A
	WHERE A.RecID <> ISNULL(@RecID, 0) AND 
		((@Bdate BETWEEN A.BeginDate AND ISNULL(A.EndDate, A.BeginDate)) OR (ISNULL(@Edate, @Bdate) BETWEEN A.BeginDate AND ISNULL(A.EndDate, A.BeginDate)) OR
		(A.BeginDate BETWEEN @Bdate AND ISNULL(@Edate, @Bdate)) OR (ISNULL(A.EndDate, A.BeginDate) BETWEEN @Bdate AND ISNULL(@Edate, @Bdate)))

	IF(@EDate IS NOT NULL)
	BEGIN
		IF(@Bdate > @Edate)
		BEGIN
			--SET @Err = 'MsgSys0003'--Từ ngày phải nhỏ hơn đến ngày
			--MsgImportValidateHSNV070
			SELECT @Error = ISNULL(Code,'')     
			FROM #TEMP WHERE Value=70   
			SET @Field = 'BeginDate'
			RETURN
		END
	END

	IF(@Num > 0)
	BEGIN
		--SET @Err = 'MsgSys0002'--Từ ngày, đến ngày của kinh nghiệm không được lồng nhau
		--MsgImportValidateHSNV069
		SELECT @Error = ISNULL(Code,'')    
		FROM #TEMP WHERE Value=69
		SET @Field = 'BeginDate'
		RETURN
	END     
END

	--import Cong viec thuc hien (3 keys) - tvnhuy 23/02/2021
	IF @TableName = 'HCSEM_EmpTask2'
	BEGIN

		DECLARE @taskCodeEmpTask2 varchar(30)
		DECLARE @effectDateEmpTask2 datetime
		DECLARE @recordIDEmpTask2 uniqueidentifier
		DECLARE @NumEmpTask2 int

		SELECT @taskCodeEmpTask2 = CodeValue FROM #lstOfField WHERE FieldName = 'TaskCode'
		SELECT @effectDateEmpTask2 = CodeValue FROM #lstOfField WHERE FieldName = 'EffectDate'
		SELECT @recordIDEmpTask2 = CodeValue FROM #lstOfField WHERE FieldName = 'RecordID'

		SELECT @NumEmpTask2 = COUNT(1) 
		FROM HCSEM_EmpTask2 AS A
		WHERE A.RecordID <> ISNULL(@recordIDEmpTask2, NEWID()) AND A.TaskCode = @taskCodeEmpTask2 AND A.EffectDate = @effectDateEmpTask2 AND A.EmployeeCode = @EmployeeCode

		IF(@NumEmpTask2 > 0)
		BEGIN
			--MsgImportValidateHSNV071 -- Nhân viên hiện tại đã tồn tại Công việc và Ngày hiệu lực vừa nhập
			SELECT @Error = ISNULL(Code,'')    
			FROM #TEMP WHERE Value=71
			SET @Field = 'TaskCode'
			RETURN
		END     
	END
	--tttai 19-9-2019      

	--import nhanh hsnv      
	IF @TableName = 'HCSEM_VWEmployeeTemplate' OR @TableName = 'HCSEM_View_EmployeeInfo'   
	BEGIN 
		  IF EXISTS (SELECT 1 FROM #lstOfField WHERE FieldName = 'DepartmentCode')      
		  BEGIN      
				Declare @DepImport nvarchar(30)
				SELECT @DepImport = CodeValue FROM #lstOfField WHERE FieldName = 'DepartmentCode'

				IF exists (select 1 from HCSSYS_Departments where DepartmentCode=@DepImport AND Lock=1)     --Dep Locked
				BEGIN
						SELECT @Error = ISNULL(Code,'')  FROM #TEMP WHERE Value=4300  
						SET @Field = 'DepartmentCode'
						SET @Val = @DepImport 
						RETURN
				END
				IF NOT EXISTS (SELECT 1 from HCS_SYS_Fn_GetDataAccessDomainByUserID(@UserID) where DepartmentCode=@DepImport) -- ko thuộc phân vùng của user
				BEGIN
						SELECT @Error = ISNULL(Code,'')  FROM #TEMP WHERE Value=4301
						SET @Field = 'DepartmentCode'
						SET @Val = @DepImport 
						RETURN
				END
		   END

		  IF EXISTS (SELECT 1 FROM #lstOfField WHERE FieldName = 'IDCardNo')      
		  BEGIN      
			--SELECT 'fff'
			   DECLARE @IDCardNoTT NVARCHAR(30), @BYear NVARCHAR(30) ,@IsCMND BIT, @NationCode varchar(20)
  
			   SELECT @IDCardNoTT=CodeValue FROM #lstOfField WHERE FieldName = 'IDCardNo'      
			   SELECT @BYear = CodeValue FROM #lstOfField WHERE FieldName = 'Birthday' 

				DECLARE @EmpTmpCode NVARCHAR(20), @isCusQua INT    
				SELECT @isCusQua = [Value] FROM dbo.HCSSYS_SettingsForCustomers WHERE KeyCode='AQUA_CheckExistEmpByIDCardAndBYear'    
				SELECT TOP(1) @EmpTmpCode = A.EmployeeCode FROM dbo.HCSEM_EmpInfoPersonal A LEFT JOIN dbo.HCSEM_EmpInfoStopWork N ON N.EmployeeCode = A.EmployeeCode       
				WHERE  A.IDCardNo = @IDCardNoTT AND LEFT(A.Birthday, 4) = LEFT(@BYear, 4) AND A.EmployeeCode <> @EmployeeCode AND ISNULL(N.EndDate, '') = ''     
				IF(ISNULL(@isCusQua, 0) = 1 AND ISNULL(@EmpTmpCode, '') <> '')    
				BEGIN    
					INSERT INTO HCSEM_Employees_importTmp(UserID,EmployeeCode,FieldCode,Kind,Note,CreatedOn,CreatedBy)      
					VALUES (@UserID,@EmployeeCode, 'IDCardNo', 0, N'Đã tồn tại số CMND & Năm sinh ('       
						+ ISNULL(@EmpTmpCode,'') + ')',GETDATE(), @UserID)      
				END  

			   -- begin vvphuoc 20201231
			   SELECT @IsCMND = CodeValue FROM #lstOfField WHERE FieldName = 'IsCMND'
			   SELECT @NationCode = CodeValue FROM #lstOfField WHERE FieldName = 'NationCode'
			   IF ISNULL(@IsCMND,0) = 1 AND ISNULL(@IDCardNoTT,'') <> '' 
			    AND (Not exists (select top(1) SL from HCSEM_FnCheckIsForeigner(@EmployeeCode,1)))
			   AND (isnull(@NationCode,'') = '' or @NationCode = 'vn')
			   BEGIN      
				   EXEC HCSSYS_spImportValidateCMND @IDCardNoTT, 1, @result OUTPUT 
				   IF @result=0
				   BEGIN
				   --SET @Error = N'Độ dài CMND phải = 9'  
					   SELECT @Error = ISNULL(Code,'')     
						FROM #TEMP WHERE Value=17    
						SET @Field = 'IDCardNo'      
						SET @Val = @IDCardNoTT 
						
						RETURN      
				   END
				   IF EXISTS (SELECT 1 FROM HCSEM_VWEmployees_info WHERE IDCardNo=@IDCardNoTT AND EmployeeCode <> @EmployeeCode 
								AND ISNULL(Birthday + EmployeeName,'') <> @strCmp)
							AND (Not exists (select top(1) SL from HCSEM_FnCheckIsForeigner(@EmployeeCode,1)))
							 AND (isnull(@NationCode,'') = '' or @NationCode = 'vn')
					BEGIN
					   IF ISNULL(@HSNV_IsValidateCMND,0) = 0
					   BEGIN
							SELECT @Error = ISNULL(Code,'')     
							FROM #TEMP WHERE Value=11 
							SET @Field = 'IDCardNo'      
							SET @Val = @IDCardNoTT 
							
							SELECT @EmpTmpCode = EmployeeCode FROM HCSEM_VWEmployees_info WHERE IDCardNo=@IDCardNoTT AND EmployeeCode <> @EmployeeCode 
								AND ISNULL(Birthday + EmployeeName,'') <> @strCmp

							INSERT INTO HCSEM_Employees_importTmp(UserID,EmployeeCode,FieldCode,Kind,Note,CreatedOn,CreatedBy)      
							VALUES (@UserID,@EmployeeCode, 'IDCardNo', 0, N'Đã tồn tại số CMND (' + ISNULL(@EmpTmpCode,'') + ')',GETDATE(), @UserID)
							return
					   END
					END
			   END      

			  IF ISNULL(@IsCMND,0) = 0 AND ISNULL(@IDCardNoTT,'') <> ''  
			  AND (Not exists (select top(1) SL from HCSEM_FnCheckIsForeigner(@EmployeeCode,1)))
			   AND (isnull(@NationCode,'') = '' or @NationCode = 'vn')
			   BEGIN      
				   EXEC HCSSYS_spImportValidateCMND @IDCardNoTT, 0, @result OUTPUT 
				   IF @result = 0
				   BEGIN
						--SET @Error = N'Độ dài Thẻ căn cước phải = 12'    
						SELECT @Error = ISNULL(Code,'') FROM #TEMP WHERE Value=18    
						SET @Field = 'IDCardNo'      
						SET @Val = @IDCardNoTT       
						RETURN      
					END    
					IF EXISTS (SELECT 1 FROM HCSEM_VWEmployees_info WHERE IDCardNo=@IDCardNoTT AND EmployeeCode <> @EmployeeCode 
								AND ISNULL(Birthday + EmployeeName,'') <> @strCmp)
								AND (Not exists (select top(1) SL from HCSEM_FnCheckIsForeigner(@EmployeeCode,1)))
							AND (isnull(@NationCode,'') = '' or @NationCode = 'vn')
					BEGIN
						IF ISNULL(@HSNV_IsValidateCMND,0) = 0
						BEGIN
							SELECT @Error = ISNULL(Code,'')     
							FROM #TEMP WHERE Value=12    
							SET @Field = 'IDCardNo'      
							SET @Val = @IDCardNoTT   

							SELECT @EmpTmpCode = EmployeeCode FROM HCSEM_VWEmployees_info WHERE IDCardNo=@IDCardNoTT AND EmployeeCode <> @EmployeeCode 
								AND ISNULL(Birthday + EmployeeName,'') <> @strCmp

							INSERT INTO HCSEM_Employees_importTmp(UserID,EmployeeCode,FieldCode,Kind,Note,CreatedOn,CreatedBy)      
							VALUES (@UserID,@EmployeeCode, 'IDCardNo', 0, N'Đã tồn tại số thẻ căn cước (' + ISNULL(@EmpTmpCode,'') + ')',GETDATE(), @UserID)
							RETURN
						END
					END
				END  
		  END   
		  
		  IF EXISTS (SELECT 1 FROM #lstOfField WHERE FieldName = 'IDCardNo2')      
		  BEGIN      
			   DECLARE @IDCardNo2TT NVARCHAR(30)      
    
			   SELECT @IDCardNo2TT=CodeValue FROM #lstOfField WHERE FieldName = 'IDCardNo2'      
			   IF ISNULL(@IDCardNo2TT,'') <> '' AND EXISTS (SELECT 1 FROM HCSEM_VWEmployees_info WHERE IDCardNo2=@IDCardNo2TT AND EmployeeCode <> @EmployeeCode 
								AND ISNULL(Birthday + EmployeeName,'') <> @strCmp )      
			   BEGIN      
					--SET @Error = N'Đã tồn tại số thẻ căn cước.'    
					SELECT @Error = ISNULL(Code,'')     
					FROM #TEMP WHERE Value=12    
					RETURN      
			   END      
		  END      
  
		  IF EXISTS (SELECT 1 FROM #lstOfField WHERE FieldName = 'CodeTax')      
		  BEGIN      
			   DECLARE @CodeTaxTT NVARCHAR(30)      
			   SET @EmployeeCode = ''      
			   SELECT @EmployeeCode = CodeValue FROM #lstOfField WHERE FieldName = 'EmployeeCode'      
			   SELECT @CodeTaxTT=CodeValue FROM #lstOfField WHERE FieldName = 'CodeTax' 
			   IF @CodeTaxTT IS NOT NULL AND LEN(@CodeTaxTT)>0
			   BEGIN
					IF LEN(@CodeTaxTT) <> 10
					   BEGIN
						SELECT @Error = ISNULL(Code,'')     
							FROM #TEMP WHERE Value=62    
							SET @Field = 'CodeTax'      
							SET @Val = @CodeTaxTT       
							RETURN      
					   END
					   IF LEN(@CodeTaxTT) = 10
					   BEGIN
						DECLARE @strCodeTaxTT bigint
							BEGIN TRY
									SELECT @strCodeTaxTT=CAST(@CodeTaxTT AS bigint)
							END TRY
							BEGIN CATCH
							END CATCH
							IF(@strCodeTaxTT is null)
							BEGIN
								SELECT @Error = ISNULL(Code,'')
								 FROM #TEMP WHERE Value=62
								SET @Field = 'CodeTax'      
								SET @Val = @CodeTaxTT 
								return
							END        
					   END
					   
			   end
		  END     

		  IF EXISTS (SELECT 1 FROM #lstOfField WHERE FieldName = 'SIBook')      
		  BEGIN      
			   DECLARE @SIBookTT NVARCHAR(30)      
			   SELECT @SIBookTT=CodeValue FROM #lstOfField WHERE FieldName = 'SIBook'   
			   IF @SIBookTT is NOT NULL AND LEN(@SIBookTT) > 0
			   BEGIN
					IF LEN(@SIBookTT) <> 10
					BEGIN
						SELECT @Error = ISNULL(Code,'')
						FROM #TEMP WHERE Value=58  
						SET @Field = 'SIBook'      
						SET @Val = @SIBookTT 
						return
					END
					IF LEN(@SIBookTT) = 10
					BEGIN
						DECLARE @stringSIBookTT bigint
						BEGIN TRY
						SELECT @stringSIBookTT=CAST(@SIBookTT AS bigint)
						END TRY
						BEGIN CATCH
						END CATCH
						IF(@stringSIBookTT is null)
						BEGIN
							SELECT @Error = ISNULL(Code,'')
							FROM #TEMP WHERE Value=58  
							SET @Field = 'SIBook'      
							SET @Val = @SIBookTT 
							return
						END
					END
				END
		  END  
		  
		  --BHYT
		  IF EXISTS (SELECT 1 FROM #lstOfField WHERE FieldName = 'HIBook')      
		  BEGIN      
			   DECLARE @HIBookTT NVARCHAR(30)      
  
			   SELECT @HIBookTT=CodeValue FROM #lstOfField WHERE FieldName = 'HIBook' 
			   IF @HIBookTT IS NOT NULL AND LEN(@HIBookTT)>0
			   BEGIN
				   IF LEN(@HIBookTT) <> 15 AND LEN(@HIBookTT) <> 10
						   BEGIN
							SELECT @Error = ISNULL(Code,'')
							 FROM #TEMP WHERE Value=60
							SET @Field = 'HIBook'      
							SET @Val = @HIBookTT 
							return
					END	 

					IF EXISTS (SELECT TOP(1) 1 FROM dbo.HCSEM_EmpInfoInsurance EI  inner join dbo.HCSEM_VWEmployees_info A on EI.EmployeeCode=A.EmployeeCode
							WHERE  EI.HIBook = @HIBookTT AND EI.EmployeeCode <> @EmployeeCode AND ISNULL(A.Birthday + A.EmployeeName,'') <> @strCmp)
					BEGIN      	
						SELECT @Error = ISNULL(Code,'')     
						  FROM #TEMP WHERE Value=13    
						RETURN      
				   END  
	  
			   end
		  END   
		  
		  --Email
		  IF EXISTS (SELECT 1 FROM #lstOfField WHERE FieldName = 'Email')      
		  BEGIN      
			   DECLARE @EmailTT NVARCHAR(250)      
    
			   SELECT @EmailTT=CodeValue FROM #lstOfField WHERE FieldName = 'Email' 
			   IF @EmailTT IS NOT NULL AND LEN(@EmailTT)>0
			   BEGIN
					EXEC  HCSSYS_spCheckEmailImport @EmailTT,@EmployeeCode,N'Email', @resultEmail OUTPUT
					IF @resultEmail =0
					BEGIN
						SELECT @Error = ISNULL(Code,'')     
								FROM #TEMP WHERE Value=65   
								SET @Field = 'Email'      
								SET @Val = @EmailTT       
					END
				END
			END

		  IF EXISTS (SELECT 1 FROM #lstOfField WHERE FieldName = 'PersonalEmail')      
		  BEGIN      
			   DECLARE @PersonalEmailTT NVARCHAR(250)      
      
			   SELECT @PersonalEmailTT=CodeValue FROM #lstOfField WHERE FieldName = 'PersonalEmail' 
			   IF @PersonalEmailTT IS NOT NULL AND LEN(@PersonalEmailTT)>0
			   BEGIN 
						EXEC  HCSSYS_spCheckEmailImport @PersonalEmailTT,@EmployeeCode,N'PersonalEmail', @resultEmailPer OUTPUT
						IF @resultEmailPer =0
						BEGIN
							SELECT @Error = ISNULL(Code,'')     
									FROM #TEMP WHERE Value=65   
									SET @Field = 'PersonalEmail'      
									SET @Val = @PersonalEmailTT       
						END
				END
			END

		  --SDT
		  IF EXISTS (SELECT 1 FROM #lstOfField WHERE FieldName = 'Mobile')      
		  BEGIN      
			   DECLARE @PhoneTT NVARCHAR(max)      
			   SELECT @PhoneTT=CodeValue FROM #lstOfField WHERE FieldName = 'Mobile' 
			   IF @PhoneTT IS NOT NULL AND LEN(@PhoneTT)>0
			   BEGIN
				  EXEC HCSSYS_spCheckMobileImport @PhoneTT, @ResultMobile OUTPUT
					IF @ResultMobile = 0 
					BEGIN
						SELECT @Error = ISNULL(Code,'')  FROM #TEMP WHERE Value=67  
						 SET @Field = 'Mobile'
						  RETURN
					end
				END	 
	  
		   END

		  IF EXISTS (SELECT 1 FROM #lstOfField WHERE FieldName = 'PPhone')      
		  BEGIN      
			   DECLARE @PPhoneTT NVARCHAR(max)      
     
			   SELECT @PPhoneTT=CodeValue FROM #lstOfField WHERE FieldName = 'PPhone' 
			   IF @PPhoneTT IS NOT NULL AND LEN(@PPhoneTT)>0
			   BEGIN
				  EXEC HCSSYS_spCheckMobileImport @PPhoneTT, @ResultPPhone OUTPUT
					IF @ResultPPhone = 0 
					BEGIN
						SELECT @Error = ISNULL(Code,'')  FROM #TEMP WHERE Value=66  
						 SET @Field = 'PPhone'
						  RETURN
					end
				END	 
	  
		   END

		  IF EXISTS (SELECT 1 FROM #lstOfField WHERE FieldName = 'TPhone')      
		  BEGIN      
			   DECLARE @TPhoneTT NVARCHAR(max)      
     
			   SELECT @TPhoneTT=CodeValue FROM #lstOfField WHERE FieldName = 'TPhone' 
			   IF @TPhoneTT IS NOT NULL AND LEN(@PPhoneTT)>0
			   BEGIN
				  EXEC HCSSYS_spCheckMobileImport @TPhoneTT, @ResultTPhone OUTPUT
					IF @ResultPPhone = 0 
					BEGIN
						SELECT @Error = ISNULL(Code,'')  FROM #TEMP WHERE Value=66  
						 SET @Field = 'TPhone'
						  RETURN
					end
				END	   
		   END

		  IF EXISTS (SELECT 1 FROM #lstOfField WHERE FieldName = 'UserID')      
		  BEGIN      
				--SELECT CodeValue FROM #lstOfField WHERE FieldName = 'UserID'
				--RETURN

			   DECLARE @UserID_LoginAcc NVARCHAR(max)      
     
			   SELECT @UserID_LoginAcc = CodeValue FROM #lstOfField WHERE FieldName = 'UserID' 
			   IF @UserID_LoginAcc IS NOT NULL AND LEN(@UserID_LoginAcc)>0
			   BEGIN
				  EXEC HCSSYS_spCheckUserID_LoginAcc @UserID_LoginAcc, @ResultUserID_LoginAcc OUTPUT
					IF @ResultUserID_LoginAcc = 0 
					BEGIN
						SELECT @Error = ISNULL(Code,'')  FROM #TEMP WHERE Value=73  
						SET @Field = 'UserID'
						SET @Val = @UserID_LoginAcc 
						RETURN
					END
				END	   
		   END

		  IF EXISTS (SELECT TOP(1) 1 FROM dbo.HCSSYS_SettingsForCustomers WHERE KeyCode='KC_VisibleRoute' AND Value = 1)      
		  BEGIN      
			   IF EXISTS (SELECT 1 FROM #lstOfField WHERE FieldName = 'RouteCode')      
			   AND EXISTS (SELECT 1 FROM #lstOfField WHERE FieldName = 'EmployeeCode')      
			   BEGIN      
					DECLARE @Route NVARCHAR(10)      
					DECLARE @strE NVARCHAR(300)      
        
					SELECT @Route = CodeValue FROM #lstOfField WHERE FieldName = 'RouteCode'      
      
					SET @strE =''      
					DECLARE @ExistsRoute NVARCHAR(20)  
          
					SELECT TOP(1) @ExistsRoute = A.RouteCode, @strE = (A.LastName + N' ' + A.FirstName) + ' - ' + A.EmployeeCode, @EndDate = B.EndDate      
					FROM dbo.HCSEM_Employees A WITH (NOLOCK) LEFT JOIN dbo.HCSEM_EmpInfoStopWork B WITH (NOLOCK) ON B.EmployeeCode = A.EmployeeCode      
					WHERE A.RouteCode = @Route AND A.EmployeeCode <> @EmployeeCode --      
          
					IF(ISNULL(@strE, '') <> '' AND ISNULL(@EndDate, '') = '')      
					BEGIN      
					 --SET @Error = N'Bạn không thể gán Route cho nhân viên này. Route đã được thiết lập cho: ' + @strE    
					  SELECT @Error = ISNULL(Code,'')     
					  FROM #TEMP WHERE Value=14    
						 SET @Error=@Error+N'$'+@strE    
    
						 SET @Field = 'RouteCode'      
						 SET @Val = @Route       
						 RETURN      
					END      
			   END      
		  END        
	END  

	IF @TableName = 'HCSPR_ExternalCustomer_Tax_tmp'
	BEGIN 	
		  DECLARE   @IDCardNo_Tax nvarchar(50), @CodeTax_Tax nvarchar(50), @Email_Tax NVARCHAR(100), @Mobile_Tax nvarchar(100),@result_tax int, @errstr_tax nvarchar(1000)
		  IF EXISTS (SELECT 1 FROM #lstOfField WHERE FieldName = 'IDCardNo')      
		  BEGIN  
				SELECT @IDCardNo_Tax=RTRIM(LTRIM(CodeValue)) FROM #lstOfField WHERE FieldName = 'IDCardNo' 
				IF LEN(@IDCardNo_Tax) <> 9 AND LEN(@IDCardNo_Tax) <> 12
				BEGIN
				   SELECT @Error = ISNULL(Code,'')     
					FROM #TEMP WHERE Value=17    
					SET @Field = 'IDCardNo'      
					SET @Val = @IDCardNo_Tax 
					RETURN      
				END
		  END   
		  IF EXISTS (SELECT 1 FROM #lstOfField WHERE FieldName = 'CodeTax')      
		  BEGIN      
			  
			   SELECT @CodeTax_Tax=RTRIM(LTRIM(CodeValue)) FROM #lstOfField WHERE FieldName = 'CodeTax' 
			   IF LEN(@CodeTaxTT) <> 10 AND LEN(@CodeTaxTT) <> 13
				BEGIN
					SELECT @Error = ISNULL(Code,'')     
					FROM #TEMP WHERE Value=62    
					SET @Field = 'CodeTax'      
					SET @Val = @CodeTax_Tax       
					RETURN      
				 END
		  END     
		  --Email
		  IF EXISTS (SELECT 1 FROM #lstOfField WHERE FieldName = 'Email')      
		  BEGIN     
			   SELECT @Email_Tax=CodeValue FROM #lstOfField WHERE FieldName = 'Email' 
		  END
		  -- mobile
		  IF EXISTS (SELECT 1 FROM #lstOfField WHERE FieldName = 'Mobile')      
		  BEGIN      
			   SELECT @Mobile_Tax=CodeValue FROM #lstOfField WHERE FieldName = 'Mobile' 
		   END
		-- validate mobile và codetax
		  EXEC HCSSYS_spCheckEmailImportTax @Email_Tax ,@Mobile_Tax, @Lang, null,@CodeTax_Tax, @errstr_tax out, @result_tax OUTPUT
		  IF @result_tax = 65
		  BEGIN
		  	 SELECT @Error = ISNULL(Code,'')  FROM #TEMP WHERE Value=65  
		  	 SET @Field = 'Email'
		  	 RETURN
		  end
		  ELSE IF @result_tax = 67
		  BEGIN
		  	 SELECT @Error = ISNULL(Code,'')  FROM #TEMP WHERE Value=67  
		  	 SET @Field = 'Mobile'
		  	 RETURN
		  end
	END  

	IF @TableName = 'HCSEM_EmpVacation'      
	BEGIN 
			IF EXISTS (SELECT 1 FROM #lstOfField WHERE FieldName = 'VYear')      
			AND EXISTS (SELECT 1 FROM #lstOfField WHERE FieldName = 'EmployeeCode')      
			BEGIN      
				DECLARE @VYear NVARCHAR(10)      
     
				SELECT @VYear = CodeValue FROM #lstOfField WHERE FieldName = 'VYear'      
				--SELECT '@EmployeeCode', @EmployeeCode, '@VYear', @VYear      
				IF EXISTS (SELECT 1 FROM HCSEM_EmpVacationTransfer WHERE EmployeeCode = @EmployeeCode AND VYear = LEFT(@VYear,4))      
				BEGIN      
					--SET @Error = N'Phép đã được chuyển sang năm sau'    
					SELECT @Error = ISNULL(Code,'')     
					FROM #TEMP WHERE Value=15  
					SET @Field = 'VYear'
					RETURN      
				END      
			END      
	 END  
	-- Hợp đồng lao động

	IF @TableName = 'HCSEM_EmpContract'      
	BEGIN 
		DECLARE @ContTo DATETIME, @FoEndDate DATETIME      
		SELECT @ContTo = CodeValue FROM #lstOfField WHERE FieldName = 'ContTo'    
		IF EXISTS (SELECT 1 FROM #lstOfField WHERE FieldName = 'ContTo')      
				AND EXISTS (SELECT 1 FROM #lstOfField WHERE FieldName = 'EmployeeCode')      
		BEGIN      
			 SELECT @FoEndDate = FoEndDate FROM HCSEM_EmpInfoForeigner WHERE EmployeeCode = @EmployeeCode      
			 IF @FoEndDate IS NOT NULL AND @ContTo > @FoEndDate      
			 BEGIN      
				SELECT @Error = ISNULL(Code,'')     
				FROM #TEMP WHERE Value=16    
				SET @Field = 'ContTo'      
				SET @Val = @ContTo       
				RETURN      
			 END      
		  END      
		SELECT @ContFrom = CodeValue FROM #lstOfField WHERE FieldName = 'ContFrom'      
		IF @JoinDateEmp > @ContFrom
		BEGIN
				SELECT @Error = ISNULL(Code,'')  FROM #TEMP WHERE Value=2208    
				SET @Field = 'ContFrom'      
				SET @Val = @ContFrom       
				RETURN      
		END

		SELECT @EffectDateB = CONVERT(DATE, CodeValue) FROM #lstOfField WHERE FieldName = 'EffectDateB'

		IF @EffectDateB IS NOT NULL
		BEGIN
			IF @JoinDateEmp > @EffectDateB
			BEGIN
					SELECT @Error = ISNULL(Code,'')  FROM #TEMP WHERE Value=2208    
					SET @Field = 'EffectDateB'      
					SET @Val = @ContFrom       
					RETURN      
			END
			if @ContFrom > @EffectDateB
			begin
				SELECT @Error = 'EffectDateSmallerThanFromDate'
				SET @Field = 'EmployeeCode'  
				RETURN 
			END
	
			if @ContTo IS NOT NULL AND @EffectDateB > @ContTo
			begin
				SELECT @Error = 'EffectDateBiggerThanToDate'
				SET @Field = 'EmployeeCode'  
				RETURN 
			END
		END

		-- Hợp đồng lao động
		SELECT @EffectDateBe = CONVERT(DATE, ContFrom) FROM HCSEM_EmpContract WHERE EmployeeCode = @EmpCodeLock
		SELECT @EffectDateAf = CONVERT(DATE, CodeValue) FROM #lstOfField WHERE FieldName = 'ContFrom'
		IF(@EffectDateBe <> @EffectDateAf)
		BEGIN
			SET @IDLock = 104
			DELETE #tmpLock
			INSERT INTO #tmpLock
			EXEC dbo.HCSSYS_SpCheckLockEmpData_Permission @UserID, @IDLock, @EffectDateAf, @EmpCodeLock

			SELECT @IsLock = IsLock FROM #tmpLock
			IF(@IsLock = 1)
			BEGIN			
				SELECT @Error = ISNULL(Code,'')  FROM #TEMP WHERE Value = 46
				SET @Field = 'ContFrom'
				RETURN
			END
		END
	 END    
	 
	-- End Hợp đồng lao động

	-- Phụ lục Hợp đồng lao động HCSEM_EmpWorking
	IF @TableName = 'HCSEM_VWEmpContract_PLHD'     
	BEGIN 
		-- Phụ lục Hợp đồng lao động
		SELECT @EffectDateBe = CONVERT(DATE, ContFrom) FROM HCSEM_VWEmpContract_PLHD WHERE EmployeeCode = @EmpCodeLock
		SELECT @EffectDateAf = CONVERT(DATE, CodeValue) FROM #lstOfField WHERE FieldName = 'ContFrom'
		IF(@EffectDateBe <> @EffectDateAf)
		BEGIN
			SET @IDLock = 105
			DELETE #tmpLock
			INSERT INTO #tmpLock
			EXEC dbo.HCSSYS_SpCheckLockEmpData_Permission @UserID, @IDLock, @EffectDateAf, @EmpCodeLock

			SELECT @IsLock = IsLock FROM #tmpLock
			IF(@IsLock = 1)
			BEGIN			
				SELECT @Error = ISNULL(Code,'')  FROM #TEMP WHERE Value = 46
				SET @Field = 'ContFrom'
				RETURN
			END
		END

		SELECT @ContFrom = CodeValue FROM #lstOfField WHERE FieldName = 'ContFrom'      
		IF @JoinDateEmp > @ContFrom
		BEGIN
				SELECT @Error = ISNULL(Code,'')  FROM #TEMP WHERE Value=2208    
				SET @Field = 'ContFrom'      
				SET @Val = @ContFrom       
				RETURN      
		END

		SELECT @EffectDateB = CONVERT(DATE, CodeValue) FROM #lstOfField WHERE FieldName = 'EffectDateB'

		IF @EffectDateB IS NOT NULL
		BEGIN
			IF @JoinDateEmp > @EffectDateB
			BEGIN
					SELECT @Error = ISNULL(Code,'')  FROM #TEMP WHERE Value=2208    
					SET @Field = 'EffectDateB'      
					SET @Val = @ContFrom       
					RETURN      
			END
		END

	END
	IF @TableName = 'HCSEM_EmpWorking'     
	BEGIN 
		DECLARE @EffectDate_Working datetime
		SELECT @EffectDate_Working = CodeValue FROM #lstOfField WHERE FieldName = 'EffectDate'    
		SELECT @ContFrom = CodeValue FROM #lstOfField WHERE FieldName = 'BeginDate' 
		SELECT @ContTo = CodeValue FROM #lstOfField WHERE FieldName = 'EndDate'      

		IF @JoinDateEmp > @EffectDate_Working
		BEGIN
				SELECT @Error = ISNULL(Code,'')  FROM #TEMP WHERE Value=2208    
				SET @Field = 'EffectDate'      
				SET @Val = @EffectDate_Working       
				RETURN      
		END

		SELECT @EffectDateB = CONVERT(DATE, CodeValue) FROM #lstOfField WHERE FieldName = 'EffectDateB'
		IF @EffectDateB IS NOT NULL
		BEGIN
			IF @JoinDateEmp > @EffectDateB
			BEGIN
					SELECT @Error = ISNULL(Code,'')  FROM #TEMP WHERE Value=2208    
					SET @Field = 'EffectDateB'      
					SET @Val = @ContFrom       
					RETURN      
			END
			if @ContFrom > @EffectDateB
			begin
				SELECT @Error = 'EffectDateSmallerThanFromDate'
				SET @Field = 'EmployeeCode'  
				RETURN 
			END
	
			if @ContTo IS NOT NULL AND @EffectDateB > @ContTo
			begin
				SELECT @Error = 'EffectDateBiggerThanToDate'
				SET @Field = 'EmployeeCode'  
				RETURN 
			END
		END
	END
	IF @TableName = 'HCSTS_AssignShift' AND @IsLoginBU = 1      
	BEGIN 
		INSERT INTO #lstOfData(ID,TableName, FieldName, IsMutiValue, FiledEmpCode, TableRef, FieldRef, Predicate, FiledRefBU, CodeValue)      
		SELECT T.ID,T.TableName, T.FieldName, T.IsMutiValue, T.FiledEmpCode, T.TableRef, T.FieldRef, T.Predicate, T.FiledRefBU, S.CodeValue       
		FROM #lstOfField S CROSS APPLY HCSSYS_ConfigFieldBU T      
		WHERE T.TableName = @TableName AND T.FieldName = 'ShiftCode' AND S.FieldName LIKE 'D20%'      
	END    
	DECLARE @CodeTaxTN VARCHAR(30), @IsReduceTax BIT	, @FromMonth NVARCHAR(7)
	DECLARE @IsHouseHolder BIT, @numIsHouse INT, @RelCode NVARCHAR(30)   
	IF @TableName = 'HCSEM_EmpFamily'      
	BEGIN 
	-------------------------------------- begin Khóa nhập liệu nhân viên - Thân nhân (tvnhuy: 24/12/2020) --------------------------------------
		-- Thân nhân
		SET @IDLock = 9
		DELETE #tmpLock
		INSERT INTO #tmpLock
		EXEC dbo.HCSSYS_SpCheckLockEmpData_Permission @UserID, @IDLock, @Now, @EmpCodeLock
		
		SELECT @IsLock = IsLock FROM #tmpLock
		IF(@IsLock = 1)
		BEGIN
			SELECT @Error = ISNULL(Code,'')  FROM #TEMP WHERE Value = 44
			SET @Field = 'EmployeeCode'    
			RETURN
		END
	-------------------------------------- end Khóa nhập liệu nhân viên - Thân nhân (tvnhuy: 24/12/2020) --------------------------------------
		DECLARE @IsCM BIT, @IDCard VARCHAR(30)
		 --@Birthdate,         -- varchar(20)
		 --                                        1,          -- bit
		 --                                        @IDCard,             -- nvarchar(20)
		 --                                        @SoDinhDanh,       -- nvarchar(30)
		 --                                        @CodeTaxTN,         -- nvarchar(20)
		 --                                        @RecID,      
		 DECLARE @SoDinhDanh NVARCHAR(20)
		SELECT @CodeTaxTN = CodeValue FROM #lstOfField WHERE FieldName = 'CodeTax' 
		DECLARE @SIBookTN VARCHAR(20)
		SELECT @SIBookTN=CodeValue FROM #lstOfField WHERE FieldName = 'SIBook' 
		DECLARE @HIBookTN VARCHAR(20)
		SELECT @HIBookTN=CodeValue FROM #lstOfField WHERE FieldName = 'HIBook' 
		SELECT @JobPhoneTN=CodeValue FROM #lstOfField WHERE FieldName = 'JobPhone' 
		SELECT @TPhoneTN=CodeValue FROM #lstOfField WHERE FieldName = 'TPhone' 
		SELECT @PPhoneTN=CodeValue FROM #lstOfField WHERE FieldName = 'PPhone' 		
		SELECT @RecID=CodeValue FROM #lstOfField WHERE FieldName = 'RecID' 
		SELECT @FirstName=CodeValue FROM #lstOfField WHERE FieldName = 'FirstName' 
		SELECT @LastName=CodeValue FROM #lstOfField WHERE FieldName = 'LastName' 
		SELECT @Birthday=CodeValue FROM #lstOfField WHERE FieldName = 'Birthday' 
		SELECT @IsReduceTax=CodeValue FROM #lstOfField WHERE FieldName = 'IsReduceTax' 
		SELECT @FromMonth=CodeValue FROM #lstOfField WHERE FieldName = 'FromMonth' 
		SELECT @RelCode = CodeValue FROM #lstOfField WHERE FieldName = 'RelCode'  
		SELECT @Birthdate = CodeValue FROM #lstOfField WHERE FieldName = 'Birthdate'
		SELECT @IDCard = CodeValue FROM #lstOfField WHERE FieldName = 'IDCardNo'
		SELECT @SoDinhDanh = CodeValue FROM #lstOfField WHERE FieldName = 'BirthIDNumber'
		DECLARE @IsChildren bit
		
		SELECT @IsChildren = IsChildren FROM dbo.HCSLS_Relationship WHERE RelCode =  ISNULL(@RelCode,'') 

		IF ISNULL(@IsChildren,0) <> 1 AND ISNULL(@IsReduceTax,0) = 1 AND ISNULL(@FromMonth,'') = ''
		BEGIN
			SELECT @Error = N'Chưa chọn từ tháng giảm trừ'   
			SET @Field = 'FromMonth'      
			--SET @Val = @IDCard       
			RETURN
		END

		IF EXISTS (SELECT 1 FROM #lstOfField WHERE FieldName = 'IDCardNo')      
		AND EXISTS (SELECT 1 FROM #lstOfField WHERE FieldName = 'EmployeeCode')      
		BEGIN      
       
		
    
		SELECT @IDCard = CodeValue FROM #lstOfField WHERE FieldName = 'IDCardNo'      
		SELECT @IsCM = CodeValue FROM #lstOfField WHERE FieldName = 'IsCMND'   
    
		--validate CMND
		-- IF @IsCM = 1 AND @IDCard IS NOT NULL AND LEN(@IDCard) <> 9      
		IF @IsCM = 1 AND @IDCard IS NOT NULL AND (Not exists (select top(1) SL from HCSEM_FnCheckIsForeigner(@EmployeeCode,2)))
		BEGIN  
		EXEC HCSSYS_spImportValidateCMND @IDCard, 1, @result OUTPUT 
		IF @result=0
		BEGIN
		--SET @Error = N'Độ dài CMND phải = 9'  
			SELECT @Error = ISNULL(Code,'')     
			FROM #TEMP WHERE Value=17   
			SET @Field = 'IDCardNo'      
			SET @Val = @IDCard       
			RETURN      
		END
		END      
		IF @IsCM = 0 AND @IDCard IS NOT NULL AND LEN(@IDCard) <> 12   AND (Not exists (select top(1) SL from HCSEM_FnCheckIsForeigner(@EmployeeCode,2)))   
		BEGIN      
			EXEC HCSSYS_spImportValidateCMND @IDCard, 0, @result OUTPUT 
			IF @result = 0
			BEGIN
			--SET @Error = N'Độ dài Thẻ căn cước phải = 12'    
					SELECT @Error = ISNULL(Code,'')     
					FROM #TEMP WHERE Value=18    
				SET @Field = 'IDCardNo'      
				SET @Val = @IDCard       
				RETURN      
			END 
		end
		END      
		IF EXISTS (SELECT 1 FROM #lstOfField WHERE FieldName = 'IsHouseHolder')      
		AND EXISTS (SELECT 1 FROM #lstOfField WHERE FieldName = 'EmployeeCode')      
		BEGIN      
        
		   
     
		SELECT @IsHouseHolder = CodeValue FROM #lstOfField WHERE FieldName = 'IsHouseHolder'      
		    
		SELECT @numIsHouse = COUNT(1) FROM dbo.HCSEM_EmpFamily WHERE EmployeeCode=@EmployeeCode AND IsHouseHolder = 1 AND RelCode <> @RelCode      
      
		IF (ISNULL(@IsHouseHolder, 0) = 1 AND ISNULL(@numIsHouse, 0) = 1)      
		BEGIN      
			--SET @Error = N'Đã tồn tại thông tin Chủ hộ'    
		SELECT @Error = ISNULL(Code,'')  FROM #TEMP WHERE Value=19    
		SET @Field = 'IsHouseHolder'      
		SET @Val = @IsHouseHolder       
		RETURN    
		RETURN      
		END      
		END     
		--validate BHXh -Thông tin pháp lý- sổ BH- sổ LD
		IF @SIBookTN IS NOT NULL AND LEN(@SIBookTN) <> 10
		BEGIN
		
			SELECT @Error = ISNULL(Code,'')
					FROM #TEMP WHERE Value=58  
				SET @Field = 'SIBook'      
				SET @Val = @SIBookTN 
				return
            
		END
		IF @SIBookTN IS NOT NULL AND LEN(@SIBookTN) = 10
		BEGIN
			DECLARE @stringSIBookTN bigint
			BEGIN TRY
					SELECT @stringSIBookTN=CAST(@SIBookTN AS bigint)
			END TRY
			BEGIN CATCH
			END CATCH
			IF(@stringSIBookTN is null)
			BEGIN
				SELECT @Error = ISNULL(Code,'')
					FROM #TEMP WHERE Value=58  
				SET @Field = 'SIBook'      
				SET @Val = @SIBookTN 
				return
			END
      
		END
	
		IF @HIBookTN IS NOT NULL AND LEN(@HIBookTN) <> 15 AND LEN(@HIBookTN) <> 10
		BEGIN
			SELECT @Error = ISNULL(Code,'')
					FROM #TEMP WHERE Value=60
				SET @Field = 'HIBook'      
				SET @Val = @HIBookTN 
				return

		END
   
		--validate Mã số thuế
 
		IF @CodeTaxTN IS NOT NULL AND LEN(@CodeTaxTN) <> 10
		BEGIN
		SELECT @Error = ISNULL(Code,'')     
			FROM #TEMP WHERE Value=62    
			SET @Field = 'CodeTax'      
			SET @Val = @CodeTaxTN       
			RETURN      
		END
		IF @CodeTaxTN IS NOT NULL AND LEN(@CodeTaxTN) = 10
		BEGIN
		DECLARE @strCodeTaxTN bigint
			BEGIN TRY
					SELECT @strCodeTaxTN=CAST(@CodeTaxTN AS bigint)
			END TRY
			BEGIN CATCH
			END CATCH
			IF(@strCodeTaxTN is null)
			BEGIN
				SELECT @Error = ISNULL(Code,'')
					FROM #TEMP WHERE Value=62
				SET @Field = 'CodeTax'      
				SET @Val = @CodeTaxTN 
				return
			END        
		END
		--valid số điện thoại 20201231
  
		IF @PPhoneTN IS NOT NULL AND LEN(@PPhoneTN) > 0
			BEGIN
			EXEC HCSSYS_spCheckMobileImport @PPhoneTN, @ResultPPhone OUTPUT
			IF @ResultPPhone = 0 
			BEGIN
				SELECT @Error = ISNULL(Code,'')  FROM #TEMP WHERE Value=66    
					SET @Field = 'PPhone'
					RETURN
			end
			END
		IF @TPhoneTN IS NOT NULL AND LEN(@TPhoneTN) > 0
			BEGIN
			EXEC HCSSYS_spCheckMobileImport @TPhoneTN, @ResultTPhone OUTPUT
		
			IF @ResultTPhone = 0 
			BEGIN
				SELECT @Error = ISNULL(Code,'')  FROM #TEMP WHERE Value=66
					SET @Field = 'TPhone'
					RETURN
			end
			END
		IF @JobPhoneTN IS NOT NULL AND LEN(@JobPhoneTN) > 0
			BEGIN
			EXEC HCSSYS_spCheckMobileImport @JobPhoneTN, @ResultJobPhone OUTPUT
			IF @ResultJobPhone = 0 
			BEGIN
				SELECT @Error = ISNULL(Code,'')  FROM #TEMP WHERE Value=68   
					SET @Field = 'JobPhone'
					RETURN
			end
			END

		IF @JobPhoneTN IS NOT NULL AND LEN(@JobPhoneTN) > 0
			BEGIN
			EXEC HCSSYS_spCheckMobileImport @JobPhoneTN, @ResultJobPhone OUTPUT
			IF @ResultJobPhone = 0 
			BEGIN
				SELECT @Error = ISNULL(Code,'')  FROM #TEMP WHERE Value=68   
					SET @Field = 'JobPhone'
					RETURN
			end
			END

		DECLARE @strErr NVARCHAR(250);
		SET @strErr = ''
		EXEC dbo.HCSEM_spEmpFamily_CheckValidate @UserID,           -- nvarchar(20)
		                                         @Lang,             -- nvarchar(10)
		                                         @EmployeeCode,     -- nvarchar(30)
		                                         @FirstName,        -- nvarchar(100)
		                                         @LastName,         -- nvarchar(100)
		                                         @Birthdate,         -- varchar(20)
		                                         1,          -- bit
		                                         @IDCard,             -- nvarchar(20)
		                                         @SoDinhDanh,       -- nvarchar(30)
		                                         @CodeTaxTN,         -- nvarchar(20)
		                                         @RecID,              -- bigint
		                                         @strErr OUTPUT -- nvarchar(250)
		IF ISNULL(@strErr,'') <> ''
		BEGIN
			SET @Error = @strErr 
			IF @strErr = 'existcmnd'
			BEGIN
				SET @Field = 'IDCardNo'
			END
			ELSE IF @strErr = 'existsodinhdanh'
			BEGIN
				SET @Field = 'BirthIDNumber'
			END
			ELSE IF @strErr = 'existmasothue'
			BEGIN
				SET @Field = 'CodeTax'
			END
			ELSE
            BEGIN
				SET @Field = 'EmployeeCode'
			END
			RETURN
		END
		
END
--end family
				--validate frommont-tomonth
		declare @ToMonth varchar(7)
		SELECT @FromMonth=CodeValue FROM #lstOfField WHERE FieldName = 'FromMonth' 		 
		SELECT @ToMonth=CodeValue FROM #lstOfField WHERE FieldName = 'ToMonth' 	

		if isnull(@FromMonth,'') <> '' AND (LEN(@FromMonth)  <> 7 or  (select count(1)from HCSSYS_FNSplitString(@FromMonth, '/')) <> 2)
		BEGIN
			SELECT @Error = ISNULL(Code,'')  FROM #TEMP WHERE Value=1999  
			SET @Field = 'FromMonth'
			RETURN
		END
		if isnull(@ToMonth,'') <> '' AND (LEN(@ToMonth)  <> 7 or  (select count(1)from HCSSYS_FNSplitString(@ToMonth, '/')) <> 2)
		BEGIN
			SELECT @Error = ISNULL(Code,'')  FROM #TEMP WHERE Value=1999  
			SET @Field = 'ToMonth'
			RETURN
		END
		IF isnull(@FromMonth,'') <> '' and isnull(@ToMonth,'') <> ''
		BEGIN
			if @FromMonth > @ToMonth
			SELECT @Error = ISNULL(Code,'')  FROM #TEMP WHERE Value=1998   
			SET @Field = 'FromMonth'
			RETURN
		END
		--trung thong tin than nhan (tvnhuy 02/11/2021 - khong biet lay theo recid hay lay theo cap key)
		IF NOT EXISTS (SELECT 1 FROM HCSEM_EmpFamily 
		WHERE EmployeeCode = @EmployeeCode and LastName = @LastName and FirstName = @FirstName)
		BEGIN
			SET @IsAddNew = 1
		END
		ELSE
		BEGIN
			SET @IsAddNew = 0
		END
		
		DECLARE @countExist int
		--select @EmployeeCode, @LastName, @FirstName, @Birthday, @IsAddNew,@RecID
		select @countExist = count(1) from HCSEM_EmpFamily 
		WHERE EmployeeCode = @EmployeeCode and LastName = @LastName and FirstName = @FirstName and isnull(Birthday, '') = isnull(@Birthday, '')
		if((@IsAddNew = 1 and @countExist = 1) or (@IsAddNew = 0 and @countExist = 2))
		BEGIN			
			SELECT @Error = ISNULL(Code,'')  FROM #TEMP WHERE Value=74   
			SET @Field = 'EmployeeCode'
			RETURN
		END    

	IF @TableName = 'HCSEM_Employees'      
	 BEGIN 
		-------------------------------------- begin Khóa nhập liệu nhân viên - Thông tin công việc (tvnhuy: 24/12/2020) --------------------------------------
		-- Ngày vào làm
		SELECT @JoinDateBe = CONVERT(DATE, JoinDate) FROM HCSEM_Employees WHERE EmployeeCode = @EmpCodeLock
		SELECT @JoinDateAf = CONVERT(DATE, CodeValue) FROM #lstOfField WHERE FieldName = 'JoinDate'  
		IF(@JoinDateBe <> @JoinDateAf)
		BEGIN
			SET @IDLock = 1
			DELETE #tmpLock
			INSERT INTO #tmpLock
			EXEC dbo.HCSSYS_SpCheckLockEmpData_Permission @UserID, @IDLock, @JoinDateAf, @EmpCodeLock
		
			SELECT @IsLock = IsLock FROM #tmpLock
			IF(@IsLock = 1)
			BEGIN
				SELECT @Error = ISNULL(Code,'')  FROM #TEMP WHERE Value = 43
				SET @Field = 'JoinDate'    
				RETURN
			END
		END
    
		-- Bộ phận làm việc
		SELECT @DepBe = DepartmentCode FROM HCSEM_Employees WHERE EmployeeCode = @EmpCodeLock
		SELECT @DepAf = CodeValue FROM #lstOfField WHERE FieldName = 'DepartmentCode'    
		IF(@DepBe <> @DepAf)
		BEGIN
			SET @IDLock = 3
			DELETE #tmpLock
			INSERT INTO #tmpLock
			EXEC dbo.HCSSYS_SpCheckLockEmpData_Permission @UserID, @IDLock, @Now, @EmpCodeLock

			SELECT @IsLock = IsLock FROM #tmpLock
			IF(@IsLock = 1)
			BEGIN			
				SELECT @Error = ISNULL(Code,'')  FROM #TEMP WHERE Value = 44
				SET @Field = 'DepartmentCode'    
				RETURN
			END
		END 
	-------------------------------------- end Khóa nhập liệu nhân viên - Thông tin công việc (tvnhuy: 24/12/2020) --------------------------------------

	  IF EXISTS (SELECT TOP(1) 1 FROM dbo.HCSSYS_SettingsForCustomers WHERE KeyCode='KC_VisibleRoute' AND Value = 1)      
	  BEGIN      
	   IF EXISTS (SELECT 1 FROM #lstOfField WHERE FieldName = 'RouteCode')      
	   AND EXISTS (SELECT 1 FROM #lstOfField WHERE FieldName = 'EmployeeCode')      
	   BEGIN      
		DECLARE @RouteCode NVARCHAR(10)      
		DECLARE @ErrNum INT, @strEmp NVARCHAR(300)      
    
		SELECT @RouteCode = CodeValue FROM #lstOfField WHERE FieldName = 'RouteCode'      
      
		EXEC HCSEM_SpCheckValidateRouteByEmployees_KC @UserID, @EmployeeCode, @RouteCode, @ErrNum OUT, @strEmp OUT      
		IF(ISNULL(@strEmp, '') <> '')      
		BEGIN      
		 --SET @Error = N'Bạn không thể gán Route cho nhân viên này. Route đã được thiết lập cho: ' + @strEmp    
	  SELECT @Error = ISNULL(Code,'')     
	  FROM #TEMP WHERE Value=20    
	  SET @Error=@Error+'$'+@strEmp    
    
		 SET @Field = 'RouteCode'      
		 SET @Val = @RouteCode       
		 RETURN      
		END      
	   END      
	  END      
    
      
	   DECLARE @UserIDVal NVARCHAR(100)    
	   SELECT @UserIDVal = CodeValue FROM #lstOfField WHERE FieldName = 'UserID'    
	   IF ISNULL(@UserIDVal,'') <> ''    
	   BEGIN    
      
        
	  IF EXISTS (SELECT 1 FROM dbo.HCSEM_Employees WHERE UserID = @UserIDVal AND EmployeeCode <> @EmployeeCode)    
	  BEGIN    
	   SELECT @Error = ISNULL(Code,'')  FROM #TEMP WHERE Value=27    
	   SET @Field = 'EmployeeCode'      
	   SET @Val = @IsHouseHolder     
	   RETURN    
	  END    
	   END    
    
	 END      
	 
	--thong tin ung vien
	IF @TableName = 'TASAT_Applicants'      
	BEGIN 
  IF EXISTS (SELECT 1 FROM #lstOfField WHERE FieldName = 'LastName')      
   OR EXISTS (SELECT 1 FROM #lstOfField WHERE FieldName = 'FirstName')      
   OR EXISTS (SELECT 1 FROM #lstOfField WHERE FieldName = 'Birthday')      
   OR EXISTS (SELECT 1 FROM #lstOfField WHERE FieldName = 'IDCardNo')      
   OR EXISTS (SELECT 1 FROM #lstOfField WHERE FieldName = 'Gender')      
   OR EXISTS (SELECT 1 FROM #lstOfField WHERE FieldName = 'Email')      
   OR EXISTS (SELECT 1 FROM #lstOfField WHERE FieldName = 'Mobile')      
  BEGIN      
   DECLARE @IDCardNo NVARCHAR(100), @Gender BIT, @Active BIT, @ApplicantCode NVARCHAR(30)      
            DECLARE @Email NVARCHAR(250), @Mobile NVARCHAR(20)      
      
   SELECT @ApplicantCode = CodeValue FROM #lstOfField WHERE FieldName = 'ApplicantCode'      
      
   SELECT @IDCardNo = CodeValue FROM #lstOfField WHERE FieldName = 'IDCardNo'      
   SELECT @Gender = CASE WHEN CodeValue='1' THEN 1 ELSE 0 end FROM #lstOfField WHERE FieldName = 'Gender'      
   SELECT @Email = CodeValue FROM #lstOfField WHERE FieldName = 'Email'      
   SELECT @Mobile = CodeValue FROM #lstOfField WHERE FieldName = 'Mobile'      
      
   EXEC HCSSYS_spImportValidateHSNV_HSUV @UserID, @Lang, @LastName, @FirstName, @BirthDate,       
      @IDCardNo,  @Gender , @Active ,  @ApplicantCode, @Email ,  @Mobile , 1 ,      
      @Error OUT,      
      @Field OUT,      
      @Val OUT,      
      @BUCodes OUT      
  END      
 END      

	IF @TableName = 'HCSSYS_DomainRolesUsers_tmp'    
	BEGIN 
  DECLARE @DDCode NVARCHAR(20), @UrsId NVARCHAR(20)    
  SELECT @DDCode = CodeValue FROM #lstOfField WHERE FieldName = 'DDCode'    
  IF ISNULL(@DDCode,'') <> ''    
  BEGIN    
   IF NOT EXISTS (SELECT 1 FROM HCSSYS_FNGetDataDomainByUserID(@UserID) S CROSS APPLY dbo.HCSSYS_fnDataDomains_getChild(S.DDCode) R    
   WHERE R.DDCode = @DDCode)    
   BEGIN    
    SELECT @UrsId = CodeValue FROM #lstOfField WHERE FieldName = 'UserID'    
    SELECT @Error = ISNULL(Code,'')  FROM #TEMP WHERE Value=26    
    SET @Field = 'UserID'      
    SET @Val = @UrsId    
    RETURN       
   END    
  END    
 END     

	IF @TableName = 'HCSEM_EmpMeal_tmp'    
	BEGIN 
  SELECT @EmpCode=CodeValue FROM #lstOfField WHERE FieldName = 'EmployeeCode'    
  SELECT @dd=CodeValue FROM #lstOfField WHERE FieldName = 'WorkDate'    
  SET @dd = CONVERT(NVARCHAR(10),@dd,111)    
  --SELECT @EmpCode,@dd    
  IF EXISTS (SELECT 1 FROM HCSTS_fnCheckLockDataTimeSheet_WithStrEmp(@EmpCode, @dd, @dd))    
  BEGIN    
   SELECT @Error = ISNULL(Code,'')  FROM #TEMP WHERE Value=28    
   SET @Field = 'UserID'      
   SET @Val = @UrsId    
   RETURN     
  END    
  SET @Error = ''    
  IF NOT EXISTS (SELECT 1 FROM dbo.HCSEM_EmpMeal WHERE EmployeeCode = @EmpCode AND WorkDate = @dd)    
   AND NOT EXISTS (SELECT 1 FROM dbo.HCSEM_EmpMeal_tmp WHERE EmployeeCode = @EmpCode AND WorkDate = @dd AND UserID=@UserID)    
  BEGIN    
   EXEC HCSEM_SPEmpMeal_Validate @UserID,@EmpCode,@dd,'', @Error OUT    
   IF ISNULL(@Error,'') <> ''    
   BEGIN    
    SET @Field = 'EmployeeCode'      
    SET @Val = @EmpCode    
    RETURN     
   END    
  END    
 END   
 
	IF @TableName = 'TASOB_Employees'    
BEGIN 
	  DECLARE @OBEmpCode NVARCHAR(100)    
	  DECLARE @EmployeeCodeOB NVARCHAR(100)    
	  SELECT @OBEmpCode = CodeValue FROM #lstOfField WHERE FieldName = 'OBEmpCode'    
	  SELECT @Email = CodeValue FROM #lstOfField WHERE FieldName = 'Email'    
	  IF ISNULL(@OBEmpCode, '') <> ''    
	  BEGIN    
	   SET @EmployeeCodeOB = ''    
	   SELECT @EmployeeCodeOB = EmployeeCode FROM dbo.TASOB_Employees WHERE OBEmpCode = @OBEmpCode    
	  END    
    
	  CREATE TABLE #tblCheckExistEmail(    
		   EmployeeCode NVARCHAR(100),    
		   FullName NVARCHAR(200),    
		   Email NVARCHAR(200),    
		   FromTable NVARCHAR(30)    
	  )    
    
	INSERT INTO #tblCheckExistEmail    
	EXEC TASOB_SpEmployeesCheckExistEmail @OBEmpCode, @EmployeeCodeOB, @Email    
    
	IF EXISTS (SELECT 1 FROM #tblCheckExistEmail)
	AND EXISTS (SELECT 1 FROM dbo.TASOB_Employees WITH(NOLOCK) WHERE Email = @Email AND Birthday <> @BirthDate)
	BEGIN    
		SELECT @Error = ISNULL(Code,'')  FROM #TEMP WHERE Value=31    
		SET @Field = 'Email'    
    
		DROP TABLE #tblCheckExistEmail    
		RETURN    
	END    
      
	DROP TABLE #tblCheckExistEmail    
 END    
  
	IF @TableName = 'HCSHP_OTRequestDetail_tmp'    
	BEGIN 
   
  IF ISNULL(@EmployeeCode,'')=''    
  BEGIN    
   SELECT @Error = ISNULL(Code,'')  FROM #TEMP WHERE Value=35    
   SET @Field = 'EmployeeCode'    
  END    
        ELSE    
  BEGIN    
   IF NOT EXISTS(SELECT 1 FROM dbo.HCSEM_Employees WHERE EmployeeCode=@EmployeeCode)    
   BEGIN    
    SELECT @Error = ISNULL(Code,'')  FROM #TEMP WHERE Value=36    
    SET @Field = 'EmployeeCode'    
   END                
  END    
    
  BEGIN TRY     
      
   SELECT @FromTime = CodeValue FROM #lstOfField WHERE FieldName = 'FromTime'    
       
   SELECT CONVERT(TIME, @FromTime)    
  END TRY      
  BEGIN CATCH      
   --SELECT ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage;      
   SELECT @Error = ISNULL(Code,'')  FROM #TEMP WHERE Value=33    
   SET @Field = 'FromTime'    
  END CATCH    
    
  BEGIN TRY     
    
   SELECT @ToTime = CodeValue FROM #lstOfField WHERE FieldName = 'ToTime'    
       
   SELECT CONVERT(TIME, @ToTime)    
  END TRY      
  BEGIN CATCH      
   --SELECT ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage;    
   SELECT @Error = ISNULL(Code,'')  FROM #TEMP WHERE Value=34    
   SET @Field = 'ToTime'    
  END CATCH      
    
  DECLARE @HourNum NVARCHAR(8)    
  SELECT @HourNum = CodeValue FROM #lstOfField WHERE FieldName = 'HourNum'    
  IF ISNULL(@HourNum,'')<>''    
  BEGIN    
   IF ISNUMERIC(@HourNum)=0    
   BEGIN    
    SELECT @Error = ISNULL(Code,'')  FROM #TEMP WHERE Value=37    
    SET @Field = 'HourNum'    
   END    
        END    
    
  DECLARE @IsPay NVARCHAR(8)    
  SELECT @IsPay = CodeValue FROM #lstOfField WHERE FieldName = 'IsPay'    
  IF ISNULL(@IsPay,'')<>''    
  BEGIN    
   IF @IsPay<>'0' AND @IsPay<>'1' AND @IsPay<>'TRUE' AND @IsPay<>'FALSE'    
   BEGIN    
    SELECT @Error = ISNULL(Code,'')  FROM #TEMP WHERE Value=38    
    SET @Field = 'IsPay'    
    RETURN    
   END    
        END    
 END    

	IF @TableName='HCSHP_FlexibleTime_Tmp'  
	BEGIN 
 declare @RegisterCode nvarchar(30)  
 declare @EmployeeCodeSub nvarchar(300)  SET @EmployeeCodeSub = @EmployeeCode
 declare @EffectDate nvarchar(30)  
 declare @EndDateFle nvarchar(30)  
 declare @RecordID UNIQUEIDENTIFIER  
 declare @IsNew BIT  
 declare @RowCount INT  
  
 declare @EffectDateSub datetime  
 declare @EndDateFleSub datetime  
  
 BEGIN TRY  
  select @RegisterCode = EmployeeCode from HCSEM_Employees where UserID=@UserID   
  SELECT @EffectDate = CodeValue FROM #lstOfField WHERE FieldName = 'EffectDate'    
  SELECT @EndDateFle = CodeValue FROM #lstOfField WHERE FieldName = 'EndDate'   
  
  SELECT @EffectDateSub=convert(datetime, @EffectDate, 103)   
  SELECT @EndDateFleSub=convert(datetime, @EndDateFle, 103) 

  if isnull(@EffectDate, '') =''
  begin
	SELECT @Error = ISNULL(Code,'')  FROM #TEMP WHERE Value=41
	SET @Error=@Error+'$'+'EffectDate'
	SET @Field = 'EffectDate'
	RETURN
  END

  if isnull(@EmployeeCodeSub, '') =''
  begin
	SELECT @Error = ISNULL(Code,'')  FROM #TEMP WHERE Value=41
	SET @Error=@Error+'$'+'EmployeeCode'
	SET @Field = 'EmployeeCode'
	RETURN
  END
  
  if not exists(select top(1) 1 from HCSEM_Employees where EmployeeCode=@EmployeeCodeSub)
  begin
	SELECT @Error = ISNULL(Code,'')  FROM #TEMP WHERE Value=36
	SET @Field = 'EmployeeCode'
	RETURN
  END
    
 END TRY     
 BEGIN CATCH      
  SELECT @Error = ISNULL(Code,'')  FROM #TEMP WHERE Value=39    
  SET @Field = 'EmployeeCode'    
 END CATCH    
   
 --SELECT @RecordID = RecordID FROM HCSHP_FlexibleTime_Tmp WHERE EmployeeCode=@EmployeeCodeSub AND UserID=@UserID  
 SELECT @RecordID = CodeValue FROM #lstOfField WHERE FieldName = 'RecordID'   
 SELECT TOP(1) @IsNew = count(EmployeeCode) FROM HCSHP_FlexibleTime WHERE RecordID=@RecordID  
 set @IsNew=ISNULL(@IsNew,0)  
  
 if @IsNew=1  
 begin  
  set @IsNew=0  
  SET @EmployeeCodeSub = CAST(@RecordID AS NVARCHAR(300))  
 END  
 ELSE  
 BEGIN  
  SET @IsNew=1  
 END  
 Declare @T Table (EmployeeCode NVARCHAR(30), EmployeeName NVARCHAR(200), DepartmentName NVARCHAR(200), EffectDate NVARCHAR(30), EndDate NVARCHAR(30), RecordID UNIQUEIDENTIFIER, IsExists SMALLINT)  
 Insert @T  exec HCSHP_SpFlexibleTimeValidate @UserID, '', @Lang, @EmployeeCodeSub, @EffectDateSub, @EndDateFleSub, @IsNew  
 Select @RowCount=count(EmployeeCode) from @T where IsExists=1  
  
 IF ISNULL(@RowCount,0)<>0  
 BEGIN  
  SELECT @Error = ISNULL(Code,'')  FROM #TEMP WHERE Value=40  
  SET @Field = 'EmployeeCode'  
 END  
 END

	--tvnhuy 17/12/2020 - khóa nhập liệu nhân viên
	IF @TableName = 'HCSEM_EmpPassport'    
BEGIN 
	
	SELECT @FromDate = CodeValue FROM #lstOfField WHERE FieldName = 'IssuedDate'    
	SELECT @ToDate = CodeValue FROM #lstOfField WHERE FieldName = 'EndDate'  

	IF (@ToDate < @FromDate)    
	BEGIN    
		SELECT @Error = ISNULL(Code,'')  FROM #TEMP WHERE Value=42    
		SET @Field = 'IssuedDate'    
		RETURN    
	END    
END

-------------------------------------- begin Khóa nhập liệu nhân viên (tvnhuy: 24/12/2020) --------------------------------------
	-- Nhóm tính lương 
	IF @TableName = 'HCSEM_EmpInfoGroupSalary'    
	BEGIN 
		-- Nhóm lương
		SELECT @GroupSalCodeBe = GroupSalCode FROM HCSEM_EmpInfoGroupSalary WHERE EmployeeCode = @EmpCodeLock
		SELECT @GroupSalCodeAf = CodeValue FROM #lstOfField WHERE FieldName = 'GroupSalCode'    
		IF(@GroupSalCodeBe <> @GroupSalCodeAf)
		BEGIN
			SET @IDLock = 4
			DELETE #tmpLock
			INSERT INTO #tmpLock
			EXEC dbo.HCSSYS_SpCheckLockEmpData_Permission @UserID, @IDLock, @Now, @EmpCodeLock

			SELECT @IsLock = IsLock FROM #tmpLock
			IF(@IsLock = 1)
			BEGIN			
				SELECT @Error = ISNULL(Code,'')  FROM #TEMP WHERE Value = 44
				SET @Field = 'GroupSalCode'    
				RETURN
			END
		END
	
		-- Nguyên tệ tính lương
		SELECT @CurrencyCodeBe = CurrencyCode FROM HCSEM_EmpInfoGroupSalary WHERE EmployeeCode = @EmpCodeLock
		SELECT @CurrencyCodeAf = CodeValue FROM #lstOfField WHERE FieldName = 'CurrencyCode'    
		IF(@CurrencyCodeBe <> @CurrencyCodeAf)
		BEGIN
			SET @IDLock = 5
			DELETE #tmpLock
			INSERT INTO #tmpLock
			EXEC dbo.HCSSYS_SpCheckLockEmpData_Permission @UserID, @IDLock, @Now, @EmpCodeLock

			SELECT @IsLock = IsLock FROM #tmpLock
			IF(@IsLock = 1)
			BEGIN			
				SELECT @Error = ISNULL(Code,'')  FROM #TEMP WHERE Value = 44
				SET @Field = 'CurrencyCode'    
				RETURN
			END
		END

		-- Biểu thuế
		SELECT @TaxCodeBe = TaxCode FROM HCSEM_EmpInfoGroupSalary WHERE EmployeeCode = @EmpCodeLock
		SELECT @TaxCodeAf = CodeValue FROM #lstOfField WHERE FieldName = 'TaxCode'    
		IF(@TaxCodeBe <> @TaxCodeAf)
		BEGIN
			SET @IDLock = 6
			DELETE #tmpLock
			INSERT INTO #tmpLock
			EXEC dbo.HCSSYS_SpCheckLockEmpData_Permission @UserID, @IDLock, @Now, @EmpCodeLock

			SELECT @IsLock = IsLock FROM #tmpLock
			IF(@IsLock = 1)
			BEGIN			
				SELECT @Error = ISNULL(Code,'')  FROM #TEMP WHERE Value = 44
				SET @Field = 'TaxCode'    
				RETURN
			END
		END
	END
	-- End Nhóm tính lương
	-- Số bảo hiểm- Số lao động
	IF @TableName = 'HCSEM_EmpInfoInsurance'    
	BEGIN 
		SET @BirthDate = '' SET @strCmp = ''
		SELECT @BirthDate = Birthday, @FirstName = FirstName, @LastName = LastName FROM HCSEM_VWEmployees_info WITH(NOLOCK) WHERE EmployeeCode = @EmployeeCode  
		SET @BirthDate =ISNULL(@BirthDate,'')
		SET @strCmp = ISNULL(@BirthDate + @LastName + N' ' + @FirstName,'')
		-- SICode HICode UICode
		-- Tham gia BH
		SELECT @SICodeBe = SICode FROM HCSEM_EmpInfoInsurance WHERE EmployeeCode = @EmpCodeLock
		SELECT @SICodeAf = CodeValue FROM #lstOfField WHERE FieldName = 'SICode'
		SELECT @HICodeBe = HICode FROM HCSEM_EmpInfoInsurance WHERE EmployeeCode = @EmpCodeLock
		SELECT @HICodeAf = CodeValue FROM #lstOfField WHERE FieldName = 'HICode'
		SELECT @UICodeBe = UICode FROM HCSEM_EmpInfoInsurance WHERE EmployeeCode = @EmpCodeLock
		SELECT @UICodeAf = CodeValue FROM #lstOfField WHERE FieldName = 'UICode'
		DECLARE @SIBook VARCHAR(20)
		SELECT @SIBook=CodeValue FROM #lstOfField WHERE FieldName = 'SIBook' 
		DECLARE @HIBook VARCHAR(20)
		SELECT @HIBook=CodeValue FROM #lstOfField WHERE FieldName = 'HIBook' 
		--validate BHXh -Thông tin pháp lý- sổ BH- sổ LD
		IF @SIBook IS NOT NULL AND LEN(@SIBook) <> 10
		BEGIN
		
			SELECT @Error = ISNULL(Code,'')
				 FROM #TEMP WHERE Value=58  
				SET @Field = 'SIBook'      
				SET @Val = @SIBook 
				return
            
		END
		IF @SIBook IS NOT NULL AND LEN(@SIBook) = 10
		BEGIN
			DECLARE @stringSI bigint
			BEGIN TRY
					SELECT @stringSI=CAST(@SIBook AS bigint)
			END TRY
			BEGIN CATCH
			END CATCH
			IF(@stringSI is null)
			BEGIN
				SELECT @Error = ISNULL(Code,'')
				 FROM #TEMP WHERE Value=58  
				SET @Field = 'SIBook'      
				SET @Val = @SIBook 
				return
			END
			IF EXISTS(SELECT 1 from HCSEM_EmpInfoInsurance EI  inner join HCSEM_VWEmployees_info A on EI.EmployeeCode=A.EmployeeCode 
							WHERE EI.SIBook=@SIBook AND EI.EmployeeCode <> @EmployeeCode AND ISNULL(A.Birthday + A.EmployeeName,'')  <> @strCmp  )
			BEGIN
				SELECT @Error = ISNULL(Code,'')
					 FROM #TEMP WHERE Value=59 
					SET @Field = 'SIBook'      
					SET @Val = @SIBook 
					return
			end
		END
	
		IF @HIBook IS NOT NULL AND LEN(@HIBook) <> 15 AND LEN(@HIBook) <> 10
		BEGIN
			SELECT @Error = ISNULL(Code,'')
				 FROM #TEMP WHERE Value=60
				SET @Field = 'HIBook'      
				SET @Val = @HIBook 
				return

		END
		IF EXISTS(SELECT 1 from HCSEM_EmpInfoInsurance EI  inner join HCSEM_VWEmployees_info A on EI.EmployeeCode=A.EmployeeCode 
							WHERE EI.HIBook=@HIBook AND EI.EmployeeCode <> @EmployeeCode AND ISNULL(A.Birthday + A.EmployeeName,'')  <> @strCmp  )
		BEGIN
			SELECT @Error = ISNULL(Code,'')
				 FROM #TEMP WHERE Value=61
				SET @Field = 'HIBook'      
				SET @Val = @HIBook 
				return
		end
		IF(@SICodeBe <> @SICodeAf OR @HICodeBe <> @HICodeAf OR @UICodeBe <> @UICodeAf)
		BEGIN
			SET @IDLock = 8
			DELETE #tmpLock
			INSERT INTO #tmpLock
			EXEC dbo.HCSSYS_SpCheckLockEmpData_Permission @UserID, @IDLock, @Now, @EmpCodeLock

			SELECT @IsLock = IsLock FROM #tmpLock
			IF(@IsLock = 1)
			BEGIN			
				SELECT @Error = ISNULL(Code,'')  FROM #TEMP WHERE Value = 44
				SET @Field = 'SICode OR HICode OR UICode'
				RETURN
			END
		END
	
	END
	-- End Số bảo hiểm- Số lao động
	
	-- Quyết toán thôi việc
	IF @TableName = 'HCSEM_VWEmpInfoStopWork'    
	BEGIN 
		-- Ngày nghỉ việc
		SELECT @EndDateBe = CONVERT(DATE, EndDate) FROM HCSEM_VWEmpInfoStopWork WHERE EmployeeCode = @EmpCodeLock
		SELECT @EndDateAf = CONVERT(DATE, CodeValue) FROM #lstOfField WHERE FieldName = 'EndDate'
		IF @EndDateAf IS NULL
		BEGIN
			DECLARE @AutoCode NVARCHAR(100)
			 SELECT @AutoCode=AutoCode FROM HCSLS_UserCodeGenConfigFunction WITH(NOLOCK) WHERE FunctionID = 'HCSHREMP01.TTTV.TV' 
			IF EXISTS (SELECT 1 FROM HCSLS_UserCodeGenConfigDetail 
			WHERE AutoCode = @AutoCode AND FactorCode = 'FACTORS_DATETIME' AND WFactor='EffectDate')
			BEGIN
				SET @Field = 'MsgImportValidateHSNV101'
				RETURN
			END
		END
		IF(@EndDateBe <> @EndDateAf)
		BEGIN
			SET @IDLock = 2
			DELETE #tmpLock
			INSERT INTO #tmpLock
			EXEC dbo.HCSSYS_SpCheckLockEmpData_Permission @UserID, @IDLock, @EndDateAf, @EmpCodeLock

			SELECT @IsLock = IsLock FROM #tmpLock
			IF(@IsLock = 1)
			BEGIN			
				SELECT @Error = ISNULL(Code,'')  FROM #TEMP WHERE Value = 45
				SET @Field = 'EndDate'
				RETURN
			END
		END
	END
	-- End Quyết toán thôi việc

	-- Lương theo vị trí công việc
	IF @TableName = 'HCSEM_EmpJWSalary'    
	BEGIN 
		-- Lương theo vị trí công việc
		SELECT @EffectDateBe = CONVERT(DATE, EffectDate) FROM HCSEM_EmpJWSalary WHERE EmployeeCode = @EmpCodeLock
		SELECT @EffectDateAf = CONVERT(DATE, CodeValue) FROM #lstOfField WHERE FieldName = 'EffectDate'
		IF(@EffectDateBe <> @EffectDateAf)
		BEGIN
			SET @IDLock = 102
			DELETE #tmpLock
			INSERT INTO #tmpLock
			EXEC dbo.HCSSYS_SpCheckLockEmpData_Permission @UserID, @IDLock, @EffectDateAf, @EmpCodeLock

			SELECT @IsLock = IsLock FROM #tmpLock
			IF(@IsLock = 1)
			BEGIN			
				SELECT @Error = ISNULL(Code,'')  FROM #TEMP WHERE Value = 46
				SET @Field = 'EffectDate'
				RETURN
			END
		END
	END
	-- End Lương theo vị trí công việc

	-- Phụ cấp
	IF @TableName = 'HCSEM_EmpAllowance'    
	BEGIN 
		declare @JoinDate datetime
		SELECT @JoinDate = JoinDate FROM HCSEM_Employees WHERE EmployeeCode = @EmployeeCode
		-- Phụ cấp
		SELECT @EffectDateBe = CONVERT(DATE, EffectDate) FROM HCSEM_EmpAllowance WHERE EmployeeCode = @EmpCodeLock
		SELECT @EffectDateAf = CONVERT(DATE, CodeValue) FROM #lstOfField WHERE FieldName = 'EffectDate'
		IF(@EffectDateBe <> @EffectDateAf)
		BEGIN
			SET @IDLock = 103
			DELETE #tmpLock
			INSERT INTO #tmpLock
			EXEC dbo.HCSSYS_SpCheckLockEmpData_Permission @UserID, @IDLock, @EffectDateAf, @EmpCodeLock

			SELECT @IsLock = IsLock FROM #tmpLock
			IF(@IsLock = 1)
			BEGIN			
				SELECT @Error = ISNULL(Code,'')  FROM #TEMP WHERE Value = 46
				SET @Field = 'EffectDate'
				RETURN
			END
		END
		IF(@JoinDate > @EffectDateAf)
		BEGIN
				SELECT @Error = ISNULL(Code,'')  FROM #TEMP WHERE Value = 2208
				SET @Field = 'EffectDate'
				RETURN
		END
	END
	-- End Phụ cấp
	-- Phụ cấp template ngang 
	IF @TableName = 'HCSEM_VwEmpListAllowance'    
	BEGIN 
		declare @sopc int,@Effdate datetime,@AlloCode varchar(20),@EmCode varchar(20)
		select @sopc = count(1) from HCSLS_AlloGrade
		DECLARE @dem INT = 1;

		WHILE @dem <= @sopc
		BEGIN
			if (not exists (select 1 from #lstOfField WHERE FieldName = 'EffectDate_'+cast(@dem as varchar(10)))
				AND Exists ((select 1 from #lstOfField WHERE FieldName = 'FixAmount_'+cast(@dem as varchar(10)))))
			BEGIN			
				SELECT @Error = ISNULL(Code,'')  FROM #TEMP WHERE Value=31399
				SET @Field = 'EffectDate_'+cast(@dem as varchar(10))
				RETURN
			END
			
			SELECT @Effdate = CONVERT(DATE, CodeValue) FROM #lstOfField WHERE FieldName = 'EffectDate_'+cast(@dem as varchar(10))
			SELECT @AlloCode = CodeValue FROM #lstOfField WHERE FieldName = 'AlloGradeCode_'+cast(@dem as varchar(10))
			SELECT @EmCode = CodeValue FROM #lstOfField WHERE FieldName = 'EmployeeCode'
			
			if exists (select top(1) 1 from HCSEM_EmpAllowance with (nolock) where EmployeeCode=@EmCode AND AlloGradeCode=@AlloCode AND EffectDate=@Effdate)
			begin
					SELECT @Error = ISNULL(Code,'')  FROM #TEMP WHERE Value=31398
					SET @Field = 'AlloGradeCode_'+cast(@dem as varchar(10))
					RETURN
			END
			set @dem = @dem+1
		END
	END

	-- End Phụ cấp  template ngang 

	-- End Phụ lục Hợp đồng lao động

	-- Quá trình nghỉ phép - bù
	IF @TableName = 'HCSEM_EmpDayOff'    
	BEGIN 
		-- Quá trình nghỉ phép
		SELECT @EffectDateBe = CONVERT(DATE, BeginDate) FROM HCSEM_EmpDayOff WHERE EmployeeCode = @EmpCodeLock
		SELECT @EffectDateAf = CONVERT(DATE, CodeValue) FROM #lstOfField WHERE FieldName = 'BeginDate'
		IF(@EffectDateBe <> @EffectDateAf)
		BEGIN
			SET @IDLock = 106
			DELETE #tmpLock
			INSERT INTO #tmpLock
			EXEC dbo.HCSSYS_SpCheckLockEmpData_Permission @UserID, @IDLock, @EffectDateAf, @EmpCodeLock

			SELECT @IsLock = IsLock FROM #tmpLock
			IF(@IsLock = 1)
			BEGIN			
				SELECT @Error = ISNULL(Code,'')  FROM #TEMP WHERE Value = 47
				SET @Field = 'BeginDate'
				RETURN
			END
		END
	END
	-- End Quá trình nghỉ phép

	-- Nhật ký công tác
	IF @TableName = 'HCSEM_EmpBusinessDiary'    
	BEGIN 
		-- Nhật ký công tác
		SELECT @EffectDateBe = CONVERT(DATE, FromTime) FROM HCSEM_EmpBusinessDiary WHERE EmployeeCode = @EmpCodeLock
		SELECT @EffectDateAf = CONVERT(DATE, CodeValue) FROM #lstOfField WHERE FieldName = 'FromTime'
		IF(@EffectDateBe <> @EffectDateAf)
		BEGIN
			SET @IDLock = 108
			DELETE #tmpLock
			INSERT INTO #tmpLock
			EXEC dbo.HCSSYS_SpCheckLockEmpData_Permission @UserID, @IDLock, @EffectDateAf, @EmpCodeLock

			SELECT @IsLock = IsLock FROM #tmpLock
			IF(@IsLock = 1)
			BEGIN			
				SELECT @Error = ISNULL(Code,'')  FROM #TEMP WHERE Value = 47
				SET @Field = 'FromTime'
				RETURN
			END
		END
	END
	-- End Nhật ký công tác
	
	-- Dự án tham gia
	IF @TableName = 'HCSEM_EmpProject'    
	BEGIN 
		-- Dự án tham gia
		SELECT @EffectDateBe = CONVERT(DATE, FromDate) FROM HCSEM_EmpProject WHERE EmployeeCode = @EmpCodeLock
		SELECT @EffectDateAf = CONVERT(DATE, CodeValue) FROM #lstOfField WHERE FieldName = 'FromDate'
		IF(@EffectDateBe <> @EffectDateAf)
		BEGIN
			SET @IDLock = 109
			DELETE #tmpLock
			INSERT INTO #tmpLock
			EXEC dbo.HCSSYS_SpCheckLockEmpData_Permission @UserID, @IDLock, @EffectDateAf, @EmpCodeLock

			SELECT @IsLock = IsLock FROM #tmpLock
			IF(@IsLock = 1)
			BEGIN			
				SELECT @Error = ISNULL(Code,'')  FROM #TEMP WHERE Value = 47
				SET @Field = 'FromDate'
				RETURN
			END
		END
	END


	-- End Dự án tham gia
	DECLARE @CurrencyCode VARCHAR(20), @ExceptCode VARCHAR(20), @DateLoan DATETIME,@DeductionDate DATETIME,@FromM VARCHAR(7),@ToM VARCHAR(7)
	IF @TableName = 'HCSEM_EmpLoan'
	BEGIN
		SELECT @EmpCode = CodeValue FROM #lstOfField WHERE FieldName = 'EmployeeCode'
		SELECT @ExceptCode = CodeValue FROM #lstOfField WHERE FieldName = 'ExceptCode'
		SELECT @DateLoan = CASE WHEN CodeValue='' THEN NULL ELSE CodeValue END FROM #lstOfField WHERE FieldName = 'DateLoan'
		SELECT @Amount = CodeValue FROM #lstOfField WHERE FieldName = 'Amount'
		SELECT @CurrencyCode = CodeValue FROM #lstOfField WHERE FieldName = 'CurrencyCode'
		SELECT @FromM= CodeValue FROM #lstOfField WHERE FieldName = 'FromDate'
		SELECT @ToM = CodeValue FROM #lstOfField WHERE FieldName = 'ToDate'
		SELECT @DeductionDate = CASE WHEN CodeValue='' THEN NULL ELSE CodeValue END FROM #lstOfField WHERE FieldName = 'DeductionDate'


		INSERT INTO HCSEM_EmpLoan_tmp(EmployeeCode, ExceptCode, DateLoan, Amount, CurrencyCode, FromDate, ToDate, DeductionDate, 
				CreatedBy, UserID)
		VALUES (@EmpCode, @ExceptCode, @DateLoan, @Amount, @CurrencyCode, @FromM, @ToM, @DeductionDate, 
				@UserID, @UserID)
	END

-------------------------------------- end Khóa nhập liệu nhân viên (tvnhuy: 24/12/2020) --------------------------------------
	IF EXISTS (SELECT 1 FROM #lstOfField WHERE FieldName = 'BUCodes')      
	BEGIN 
  SELECT @BUCodes = CodeValue FROM #lstOfField WHERE FieldName = 'BUCodes'      
  --neu nhập vào là NULL hoặc trống có nghĩa áp cho toàn cty      
  IF @BUCodes = ',' OR @BUCodes =',,' SET @BUCodes = NULL      
  SET @BUCodes = RTRIM(LTRIM(@BUCodes))      
  IF ISNULL(@BUCodes,'') <> ''      
  BEGIN      
   SELECT RTRIM(LTRIM([data])) AS BuCode INTO #lstOfBU_New      
   FROM HCSSYS_FNSplitString(@BUCodes,',')       
   WHERE ISNULL(data,'') <> ''      
      
	

   IF @IsLoginBU = 0      
   BEGIN      
    --kiem tra department co thuoc phan quyen       
    DECLARE @DepCodeEx NVARCHAR(50) SET @DepCodeEx = ''      
    SELECT @DepCodeEx = S.BuCode      
    FROM #lstOfBU_New S      
    LEFT JOIN HCS_SYS_Fn_GetDataAccessDomainByUserID(@UserID) D ON D.DepartmentCode = S.BuCode      
    WHERE D.DepartmentCode IS NULL      
          
    IF ISNULL(@DepCodeEx,'') <> ''      
    BEGIN      
     --SET @Error = N'Kiểm tra mã BUCodes không tồn tại hoặc không thuộc quyền của bạn.'    
  SELECT @Error = ISNULL(Code,'')     
  FROM #TEMP WHERE Value=21    
     SET @Field = 'BUCodes'      
     SET @Val = @DepCodeEx       
    END      
   END      
   ELSE      
            BEGIN      
    --SELECT @BUCodes      
    IF EXISTS (SELECT 1 FROM #lstOfBU_New N       
      LEFT JOIN HCSSYS_Departments P ON P.DepartmentCode = N.BuCode WHERE p.DepartmentCode IS NULL OR ISNULL(p.IsBU,0) = 0)      
    BEGIN      
     --SET @Error = N'Kiểm tra mã BUCodes thêm mới không tồn tại trong hệ thống.'    
  SELECT @Error = ISNULL(Code,'')     
  FROM #TEMP WHERE Value=22    
     SET @Field = 'BUCodes'      
     SET @Val = @BUCodes       
    END      
    ELSE      
    BEGIN      
     --lay danh sach cac ma da nhap(du lieu BU cu).      
     DECLARE @FieldBU NVARCHAR(100)      
     SELECT TOP(1) @FieldBU = T1.FieldName       
     FROM HCSLS_ListToBU AS T INNER JOIN HCSLS_ConstTableBUList AS T1 ON T.TableName = T1.TableName      
     WHERE T.TableName = @TableName AND T.BUCode IS NOT NULL      
      
     --lay danh sach BU thuoc quyen user      
     select DepartmentCode INTO #lstBUOfUser FROM HCSSYS_fnGetBUByCustomer(@UserID) WHERE IsBU = 1      
     --TH UPDATE DATA      
     --CHO VÀO BU= BU OLD or null or BU thuộc quyền user      
     IF ISNULL(@FieldBU,'') <> ''      
     BEGIN      
      --lay giá trị keyCode theo BU của table      
      DECLARE @KeyValue NVARCHAR(30)      
      SELECT @KeyValue = CodeValue FROM #lstOfField WHERE FieldName = @FieldBU      
      
      SELECT T.BUCode INTO #lstOfBu_Old      
      FROM HCSLS_ListToBU AS T WITH(NOLOCK)      
      WHERE T.TableName = @TableName AND T.ValueCode = @KeyValue AND T.BUCode IS NOT NULL      
      
      DECLARE @strBu NVARCHAR(max) SET @strBu = ''      
      --danh sach BU mới nhập hợp lệ      
      SELECT @strBu = @strBu + ',' + N.BuCode      
      FROM #lstOfBU_New N      
      INNER JOIN #lstBUOfUser P ON P.DepartmentCode = N.BuCode      
           
      --field BUCodes import vào chứa BU đã tồn tại trong hệ thống AND trong tất cả các BU đó không có BU nào thuộc phân quyền của user đăng nhập  kết quả thực tế là item danh mục đó vẫn được lưu với BUCodes = NULL      
      --SELECT 'fff',@strBu      
      IF ISNULL(@BUCodes,'') <> '' AND ISNULL(@strBu,'') = ''      
      BEGIN      
       --SET @Error = N'BUCodes thêm mới không thuộc quyền của user hiện tại.'    
    SELECT @Error = ISNULL(Code,'')     
  FROM #TEMP WHERE Value=23    
       SET @Field = 'BUCodes'      
       SET @Val = @BUCodes       
      END      
      
      --danh sách BU cũ thuộc BU ko thuộc quyền của USer mà danh mục đã có sẵn      
      SELECT @strBu = @strBu + ',' + O.BUCode      
      FROM #lstOfBu_Old O      
      LEFT JOIN #lstBUOfUser P ON P.DepartmentCode = O.BUCode      
      WHERE P.DepartmentCode IS NULL      
           
      IF ISNULL(@strBu,'') = '' OR ISNULL(@strBu,'') = ',' SET @strBu = NULL      
      ELSE       
      BEGIN      
       SET @strBu = @strBu + ','      
      END      
      
      SET @BUCodes = @strBu      
     END      
     ELSE--them moi(BU thuoc quyen USer)      
     BEGIN      
      IF EXISTS (SELECT 1 FROM #lstOfBU_New N LEFT JOIN #lstBUOfUser P ON P.DepartmentCode = N.BuCode WHERE p.DepartmentCode IS NULL)      
      BEGIN      
       --SET @Error = N'BUCodes thêm mới không thuộc quyền của user hiện tại.'    
    SELECT @Error = ISNULL(Code,'')     
  FROM #TEMP WHERE Value=23    
       SET @Field = 'BUCodes'      
       SET @Val = @BUCodes       
      END      
     END      
    END      
    SET @BUCodes = REPLACE(@BUCodes,',,',',')      
   END      
  END      
 END      
       
	IF @IsLoginBU = 0 RETURN;      
      
	DECLARE @FieldName NVARCHAR(100),@IsMutiValue bit,      
			@TableRef NVARCHAR(250), @FieldRef NVARCHAR(250), @FiledRefBU NVARCHAR(250),       
			@CodeValue NVARCHAR(250),  @FiledEmpCode NVARCHAR(250)      
	DECLARE @SQL NVARCHAR(max), @BUCode NVARCHAR(100), @iCount INT, @Predicate NVARCHAR(max)      
	--SELECT TableName,FieldName,IsMutiValue,TableRef,FieldRef,FiledRefBU, CodeValue, FiledEmpCode FROM #lstOfData      
	DECLARE curtg CURSOR FOR      
	SELECT TableName,FieldName,IsMutiValue,TableRef,FieldRef, [Predicate],FiledRefBU, CodeValue, FiledEmpCode FROM #lstOfData      
	OPEN curtg      
	FETCH next from curtg into @TableName,@FieldName,@IsMutiValue,@TableRef,@FieldRef,@Predicate,@FiledRefBU, @CodeValue, @FiledEmpCode      
		WHILE @@FETCH_STATUS=0      
			BEGIN      
			IF ISNULL(@Error,'') = ''      
			BEGIN      
				SET @EmployeeCode = ''      
				SELECT @EmployeeCode = E.EmployeeCode FROM #lstOfField S LEFT JOIN HCSEM_Employees E ON E.EmployeeCode = S.CodeValue      
				WHERE FieldName = @FiledEmpCode      
      
				--SELECT @EmployeeCode      
				IF ISNULL(@EmployeeCode,'') <> ''      
				BEGIN      
					SET @BUCode = ''      
					SELECT @BUCode = ',' + ISNULL(T18.BUCode,'') + ',' FROM HCSEM_Employees E
					LEFT JOIN HCSSYS_DepartmentToBU AS T18 WITH (NOLOCK) ON E.DepartmentCode = T18.DepartmentCode WHERE E.EmployeeCode = @EmployeeCode      
      
					SET @iCount = 0      
					SET @SQL = N'select @iCount=count(1) from ' + @TableRef +       
					' where ' + @FieldRef + '=''' + @CodeValue +       
					''' and (' + @FiledRefBU + ' is null or (' +       
					@FiledRefBU + ' is not null and '+@FiledRefBU+' like N''%' + @BUCode + '%''))'      
					IF ISNULL(@Predicate,'') <> ''      
					BEGIN      
						SET @SQL = @SQL + ' AND (' + @Predicate + ')'      
					END      
					PRINT @SQL      
					EXEC sp_executesql @SQL,N'@iCount int out', @iCount OUT      
					--SELECT @iCount      
					--PRINT @SQL       
           
					IF ISNULL(@iCount,0) <= 0      
					BEGIN      
						--SET @Error = N'Mã ''{0}'' không thuộc BU của nhân viên.'      
						SELECT @Error = ISNULL(Code,'')     
						FROM #TEMP WHERE Value=24    
    
						SET @Field = @FieldName      
						SET @Val = @CodeValue      
						SET @Error=@Error+'$'+@Val     
					END      
				END      
				ELSE      
				BEGIN      
					--SET @Error = N'Cấu hình không tìm thấy mã nhân viên.'    
					SELECT @Error = ISNULL(Code,'')     
					FROM #TEMP WHERE Value=25    
    
					SET @Field = @FieldName      
					SET @Val = @CodeValue      
				END      
			END      
			FETCH NEXT FROM curtg INTO @TableName,@FieldName,@IsMutiValue,@TableRef,@FieldRef,@Predicate,@FiledRefBU, @CodeValue, @FiledEmpCode      
			END      
	CLOSE curtg      
	DEALLOCATE curtg      
	DROP TABLE #lstOfData      
	DROP TABLE #lstOfField      
END
