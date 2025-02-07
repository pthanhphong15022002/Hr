-------------------------1

USE [codx_hr]
GO
/****** Object:  UserDefinedFunction [dbo].[HR_fnFGetHT_LayThongTinLuongBatKy]    Script Date: 2/7/2025 6:28:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER FUNCTION [dbo].[HR_fnFGetHT_LayThongTinLuongBatKy](
	@EmployeeCode NVARCHAR(20),
	@DowCode VARCHAR(7),
	@ToTime DATETIME,
	@Expression VARCHAR(max),
	@Type INT
)
RETURNS FLOAT
AS
BEGIN
	
	DECLARE @result FLOAT, @tmpValue FLOAT, @FromDate DATETIME, @ToDate DATETIME, @tmpDateTime DATETIME, @Year INT, @strValue VARCHAR(20)
	SET @result = 0
	SET @Expression = LTRIM(RTRIM(@Expression))
	set @Year = year(@ToTime)

	-- Tìm kỳ lương
	SELECT TOP(1) @DowCode = DowCode, @FromDate = FromDate, @ToDate = ToDate 
	FROM dbo.HR_ConfigTSEmpStandardWD WITH (NOLOCK) 
	WHERE EmployeeID = @EmployeeCode AND FromDate < @ToTime
	ORDER BY FromDate DESC
	
	IF @Type = 1 -- Có bao nhiêu QĐ Lương
	BEGIN
		SELECT @result = COUNT(1) 
		FROM HR_PRListOfEmpSalary WITH (NOLOCK) WHERE EmployeeID = @EmployeeCode AND DowCode = @DowCode
		
		SET @result = ISNULL(@result, 0)
    END
    ELSE IF @Type = 2 -- Có bao nhiêu QĐ PC
	BEGIN
		SELECT @tmpValue = COUNT(1) 
		FROM dbo.HR_PRListOfEmpAllowance WITH (NOLOCK)
		WHERE EmployeeID = @EmployeeCode AND DowCode = @DowCode AND AlloGradeCode = @Expression
		
		SET @result = ISNULL(@tmpValue, 0)
    END
    ELSE IF @Type = 3 -- QĐ 1 Lương
	BEGIN
		IF @Expression = 'LCB'
		BEGIN
			SELECT TOP(1) @tmpValue = R.RealSalary_BS
			FROM (
				SELECT ROW_NUMBER() OVER(ORDER BY FromTime) AS RowID, RealSalary_BS 
				FROM HR_PRListOfEmpSalary WITH (NOLOCK) WHERE EmployeeID = @EmployeeCode AND DowCode = @DowCode
			) AS R WHERE R.RowID = 1

			SET @result = ISNULL(@tmpValue, 0)
		END
        ELSE IF @Expression = 'LCD'
		BEGIN
			SELECT TOP(1) @tmpValue = R.RealSalary_JW
			FROM (
				SELECT ROW_NUMBER() OVER(ORDER BY FromTime) AS RowID, RealSalary_JW 
				FROM HR_PRListOfEmpSalary WITH (NOLOCK) WHERE EmployeeID = @EmployeeCode AND DowCode = @DowCode
			) AS R WHERE R.RowID = 1

			SET @result = ISNULL(@tmpValue, 0)
		END
		ELSE IF @Expression = 'DG_LuongNG'
		BEGIN
			SELECT TOP(1) @tmpValue = R.UnitOT
			FROM (
				SELECT ROW_NUMBER() OVER(ORDER BY FromTime) AS RowID, UnitOT 
				FROM HR_PRListOfEmpSalary WITH (NOLOCK) WHERE EmployeeID = @EmployeeCode AND DowCode = @DowCode
			) AS R WHERE R.RowID = 1

			SET @result = ISNULL(@tmpValue, 0)
		END
    END 
	ELSE IF @Type = 4 -- QĐ 2 Lương
	BEGIN
		IF @Expression = 'LCB'
		BEGIN
			SELECT TOP(1) @tmpValue = R.RealSalary_BS
			FROM (
				SELECT ROW_NUMBER() OVER(ORDER BY FromTime) AS RowID, RealSalary_BS 
				FROM HR_PRListOfEmpSalary WITH (NOLOCK) WHERE EmployeeID = @EmployeeCode AND DowCode = @DowCode
			) AS R WHERE R.RowID = 2

			SET @result = ISNULL(@tmpValue, 0)
		END
        ELSE IF @Expression = 'LCD'
		BEGIN
			SELECT TOP(1) @tmpValue = R.RealSalary_JW
			FROM (
				SELECT ROW_NUMBER() OVER(ORDER BY FromTime) AS RowID, RealSalary_JW
				FROM HR_PRListOfEmpSalary WITH (NOLOCK) WHERE EmployeeID = @EmployeeCode AND DowCode = @DowCode
			) AS R WHERE R.RowID = 2

			SET @result = ISNULL(@tmpValue, 0)
		END
		ELSE IF @Expression = 'DG_LuongNG'
		BEGIN
			SELECT TOP(1) @tmpValue = R.UnitOT
			FROM (
				SELECT ROW_NUMBER() OVER(ORDER BY FromTime) AS RowID, UnitOT
				FROM HR_PRListOfEmpSalary WITH (NOLOCK) WHERE EmployeeID = @EmployeeCode AND DowCode = @DowCode
			) AS R WHERE R.RowID = 2

			SET @result = ISNULL(@tmpValue, 0)
		END
    END 
	ELSE IF @Type = 5 -- QĐ 1 PC
	BEGIN
		SELECT TOP(1) @tmpValue = R.FixAmount
		FROM (
			SELECT ROW_NUMBER() OVER(ORDER BY FromTime) AS RowID, FixAmount 
			FROM dbo.HR_PRListOfEmpAllowance WITH (NOLOCK)
			WHERE EmployeeID = @EmployeeCode AND DowCode = @DowCode AND AlloGradeCode = @Expression
		) AS R WHERE R.RowID = 1

		SET @result = ISNULL(@tmpValue, 0)
    END
    ELSE IF @Type = 6 -- QĐ 2 PC
	BEGIN
		SELECT TOP(1) @tmpValue = R.FixAmount
		FROM (
			SELECT ROW_NUMBER() OVER(ORDER BY FromTime) AS RowID, FixAmount 
			FROM dbo.HR_PRListOfEmpAllowance WITH (NOLOCK)
			WHERE EmployeeID = @EmployeeCode AND DowCode = @DowCode AND AlloGradeCode = @Expression
		) AS R WHERE R.RowID = 2

		SET @result = ISNULL(@tmpValue, 0)
    END
    ELSE IF @Type = 7 -- Ngày công chuẩn
	BEGIN
		SELECT TOP(1) @result = StandardWD
		FROM dbo.HR_ConfigTSEmpStandardWD WITH (NOLOCK) WHERE EmployeeID = @EmployeeCode AND DowCode = @DowCode
    END
    ELSE IF @Type = 8 -- Số giờ 1 công
	BEGIN
		SELECT TOP(1) @result = TSHoursPerWD
		FROM dbo.HR_ConfigTSEmp WITH (NOLOCK) WHERE EmployeeID = @EmployeeCode
    END
    ELSE IF @Type = 9
	BEGIN
		IF @Expression = 'SoNgayBoiThuong'
		BEGIN
			SELECT TOP(1) @tmpValue = OwedAmountIEDept 
			FROM dbo.HR_EmployeeExt WITH (NOLOCK) WHERE EmployeeID = @EmployeeCode
        END
		ELSE IF @Expression = 'SoThangBoiThuong'
		BEGIN
			SELECT TOP(1) @tmpValue = OwedAmountDept 
			FROM dbo.HR_EmployeeExt WITH (NOLOCK) WHERE EmployeeID = @EmployeeCode
        END
		ELSE IF @Expression = 'TuNguyen'
		BEGIN
			SELECT TOP(1) @tmpValue = Volunteer 
			FROM dbo.HR_EmployeeExt WITH (NOLOCK) WHERE EmployeeID = @EmployeeCode
        END
		ELSE IF @Expression = 'HoiTiet'
		BEGIN
			SELECT TOP(1) @tmpValue = Regret 
			FROM dbo.HR_EmployeeExt WITH (NOLOCK) WHERE EmployeeID = @EmployeeCode
        END
		-- CHưa tìm được field
		--ELSE IF @Expression = 'DaBanGiaoCongViec'
		--BEGIN
		--	SELECT TOP(1) @tmpValue = IsTransferWork 
		--	FROM dbo.HCSEM_EmpInfoStopWork WITH (NOLOCK) WHERE EmployeeID = @EmployeeCode
  --      END
		--ELSE IF @Expression = 'DaBanGiaoTaiSan'
		--BEGIN
		--	SELECT TOP(1) @tmpValue = IsTransferFortune 
		--	FROM dbo.HCSEM_EmpInfoStopWork WITH (NOLOCK) WHERE EmployeeID = @EmployeeCode
  --      END
		--ELSE IF @Expression = 'DaThanhToanCongNo'
		--BEGIN
		--	SELECT TOP(1) @tmpValue = IsPayDebt 
		--	FROM dbo.HCSEM_EmpInfoStopWork WITH (NOLOCK) WHERE EmployeeID = @EmployeeCode
  --      END
		ELSE IF @Expression = 'ConNo'
		BEGIN
			SELECT TOP(1) @tmpValue = OwedAmountFADept 
			FROM dbo.HR_EmployeeExt WITH (NOLOCK) WHERE EmployeeID = @EmployeeCode
        END
        
		SET @result = ISNULL(@tmpValue, 0)
    END 
	ELSE IF @Type = 10 -- lương theo công
	BEGIN
		;with tblList as (
			-- Lấy danh sách công cần xét
			select LTRIM(RTRIM(data)) as Code from HR_FNSplitString_varchar(@Expression, '+')
		)
		select @result = SUM(T.Amount)
		from HR_PaySalary as T with (nolock) inner join tblList as T1 on T.KowCode = T1.Code
		WHERE T.EmployeeID = @EmployeeCode AND T.DowCode = @DowCode

    END
	ELSE IF @Type = 11 -- Phụ cấp
	BEGIN
		;with tblList as (
			-- Lấy danh sách công cần xét
			select LTRIM(RTRIM(data)) as Code from HR_FNSplitString_varchar(@Expression, '+')
		)
		select @result = SUM(T.Amount)
		from dbo.HR_PayAllowance as T with (nolock) inner join tblList as T1 on T.AlloGradeCode = T1.Code
		WHERE T.EmployeeID = @EmployeeCode AND T.DowCode = @DowCode

    END
	ELSE IF @Type = 12 -- QĐ 1 Lương
	BEGIN
		IF @Expression = 'LCB'
		begin
			SELECT TOP(1) @tmpDateTime = R.FromTime
			FROM (
				SELECT ROW_NUMBER() OVER(ORDER BY FromTime) as RowID, FromTime 
				FROM HR_PRListOfEmpSalary WITH (NOLOCK) WHERE EmployeeID = @EmployeeCode AND DowCode = @DowCode
			) AS R WHERE R.RowID = 1

			SELECT TOP(1) @tmpValue = RealSalary
			FROM dbo.HR_EmpBasicSalary WITH (NOLOCK) WHERE EmployeeID = @EmployeeCode AND EffectDate <= @tmpDateTime
			ORDER BY EffectDate desc

			SET @result = ISNULL(@tmpValue, 0)
		END
        ELSE IF @Expression = 'LCD'
		begin
			SELECT TOP(1) @tmpDateTime = R.FromTime
			FROM (
				SELECT ROW_NUMBER() OVER(ORDER BY FromTime) as RowID, FromTime 
				FROM HR_PRListOfEmpSalary WITH (NOLOCK) WHERE EmployeeID = @EmployeeCode AND DowCode = @DowCode
			) AS R WHERE R.RowID = 1

			SELECT TOP(1) @tmpValue = RealSalary
			FROM dbo.HR_EmpJWSalary WITH (NOLOCK) WHERE EmployeeID = @EmployeeCode AND EffectDate <= @tmpDateTime
			ORDER BY EffectDate DESC
            
			SET @result = ISNULL(@tmpValue, 0)
		end
    END 
	ELSE IF @Type = 13 -- QĐ 2 Lương
	BEGIN
		IF @Expression = 'LCB'
		begin
			SELECT TOP(1) @tmpDateTime = R.FromTime
			FROM (
				SELECT ROW_NUMBER() OVER(ORDER BY FromTime) as RowID, FromTime 
				FROM HR_PRListOfEmpSalary WITH (NOLOCK) WHERE EmployeeID = @EmployeeCode AND DowCode = @DowCode
			) AS R WHERE R.RowID = 2

			SELECT TOP(1) @tmpValue = RealSalary
			FROM dbo.HR_EmpBasicSalary WITH (NOLOCK) WHERE EmployeeID = @EmployeeCode AND EffectDate <= @tmpDateTime
			ORDER BY EffectDate DESC
            
			SET @result = ISNULL(@tmpValue, 0)
		END
        ELSE IF @Expression = 'LCD'
		begin
			SELECT TOP(1) @tmpDateTime = R.FromTime
			FROM (
				SELECT ROW_NUMBER() OVER(ORDER BY FromTime) as RowID, FromTime 
				FROM HR_PRListOfEmpSalary WITH (NOLOCK) WHERE EmployeeID = @EmployeeCode AND DowCode = @DowCode
			) AS R WHERE R.RowID = 2

			SELECT TOP(1) @tmpValue = RealSalary
			FROM HR_EmpJWSalary WITH (NOLOCK) WHERE EmployeeID = @EmployeeCode AND EffectDate <= @tmpDateTime
			ORDER BY EffectDate DESC

			SET @result = ISNULL(@tmpValue, 0)
		end
    END 
	ELSE IF @Type = 14 -- QĐ 1 PC
	BEGIN
		SELECT TOP(1) @tmpDateTime = FromTime
		FROM (
			SELECT ROW_NUMBER() OVER(ORDER BY FromTime) as RowID, FromTime 
			FROM dbo.HR_PRListOfEmpAllowance WITH (NOLOCK)
			WHERE EmployeeID = @EmployeeCode AND DowCode = @DowCode AND AlloGradeCode = @Expression
		) AS R WHERE R.RowID = 1

		SELECT TOP(1) @tmpValue = FixAmount
		FROM HR_EmpAllowance WITH (NOLOCK) WHERE EmployeeID = @EmployeeCode AND AlloGradeCode = @Expression
			AND EffectDate <= @tmpDateTime
		ORDER BY EffectDate desc

		SET @result = ISNULL(@tmpValue, 0)
    END
    ELSE IF @Type = 15 -- QĐ 2 PC
	BEGIN
		SELECT TOP(1) @tmpDateTime = FromTime
		FROM (
			SELECT ROW_NUMBER() OVER(ORDER BY FromTime) as RowID, FromTime 
			FROM dbo.HR_PRListOfEmpAllowance WITH (NOLOCK)
			WHERE EmployeeID = @EmployeeCode AND DowCode = @DowCode AND AlloGradeCode = @Expression
		) AS R WHERE R.RowID = 2

		SELECT TOP(1) @tmpValue = FixAmount
		FROM HR_EmpAllowance WITH (NOLOCK) WHERE EmployeeID = @EmployeeCode AND AlloGradeCode = @Expression
			AND EffectDate <= @tmpDateTime
		ORDER BY EffectDate DESC
        
		SET @result = ISNULL(@tmpValue, 0)
    END
	ELSE IF @Type = 16 -- Total phu cap
	BEGIN

		set @tmpValue = 0
		;with tblList as (
			-- Lấy danh sách công cần xét
			select LTRIM(RTRIM(data)) as Code from HR_FNSplitString_varchar(@Expression, '+')
		)
		select @tmpValue = count(1), @Result = sum(FixAmount)
		from (
			select FixAmount
			from dbo.HR_PRListOfEmpAllowance as T with (nolock) inner join tblList as T1 on T.AlloGradeCode = T1.Code
			WHERE T.EmployeeID = @EmployeeCode AND T.DowCode = @DowCode
			group by FixAmount
		) as R

		-- Nếu thay đổi quyet dinh luong, trả về dung giá trị
		if @tmpValue > 1
		begin
			;with tblList as (
				-- Lấy danh sách công cần xét
				select LTRIM(RTRIM(data)) as Code from HR_FNSplitString_varchar(@Expression, '+')
			)
			select top(1) @result = T.FixAmount
			from dbo.HR_PRListOfEmpAllowance as T with (nolock) inner join tblList as T1 on T.AlloGradeCode = T1.Code
			WHERE T.EmployeeID = @EmployeeCode AND T.DowCode = @DowCode and T.FromTime < @ToTime
			order by T.FromTime desc
		end
		else
		begin
			;with tblList as (
				-- Lấy danh sách công cần xét
				select LTRIM(RTRIM(data)) as Code from HR_FNSplitString_varchar(@Expression, '+')
			)
			select @tmpValue = SUM(T.Amount)
			from dbo.HR_PayAllowance as T with (nolock) inner join tblList as T1 on T.AlloGradeCode = T1.Code
			WHERE T.EmployeeID = @EmployeeCode AND T.DowCode = @DowCode

			set @tmpValue = isnull(@tmpValue, 0)

			;with tblList as (
				-- Lấy danh sách công cần xét
				select LTRIM(RTRIM(data)) as Code from HR_FNSplitString_varchar(@Expression, '+')
			)
			select top(1) @result = T.FixAmount
			from dbo.HR_PRListOfEmpAllowance as T with (nolock) inner join tblList as T1 on T.AlloGradeCode = T1.Code
			WHERE T.EmployeeID = @EmployeeCode AND T.DowCode = @DowCode and T.FromTime < @ToTime
			order by T.FromTime desc

			set @result = isnull(@result, 0) - @tmpValue

			if @result < 0
				set @result = 0
		end
    END
	ELSE IF @Type = 17
	BEGIN
		SELECT TOP(1) @tmpDateTime = FromTime, @tmpValue = FixAmount
		FROM (
			SELECT ROW_NUMBER() OVER(ORDER BY FromTime) as RowID, FromTime, FixAmount
			FROM dbo.HR_PRListOfEmpAllowance WITH (NOLOCK)
			WHERE EmployeeID = @EmployeeCode AND DowCode = @DowCode AND AlloGradeCode = @Expression
		) AS R WHERE R.RowID = 1

		if @tmpDateTime > @FromDate and @tmpDateTime < @ToDate
			set @result = 0
		else
			SET @result = ISNULL(@tmpValue, 0)
    END
	ELSE IF @Type = 18
	BEGIN
		set @tmpDateTime = NULL
		SELECT TOP(1) @tmpDateTime = FromTime
		FROM (
			SELECT ROW_NUMBER() OVER(ORDER BY FromTime) as RowID, FromTime 
			FROM dbo.HR_PRListOfEmpAllowance WITH (NOLOCK)
			WHERE EmployeeID = @EmployeeCode AND DowCode = @DowCode AND AlloGradeCode = @Expression
		) AS R WHERE R.RowID = 2

		if @tmpDateTime is null
		begin
			SELECT TOP(1) @tmpDateTime = FromTime, @tmpValue = FixAmount
			FROM (
				SELECT ROW_NUMBER() OVER(ORDER BY FromTime) as RowID, FromTime, FixAmount
				FROM dbo.HR_PRListOfEmpAllowance WITH (NOLOCK)
				WHERE EmployeeID = @EmployeeCode AND DowCode = @DowCode AND AlloGradeCode = @Expression
			) AS R WHERE R.RowID = 1
			
			if @tmpDateTime > @FromDate and @tmpDateTime < @ToDate
				set @result = ISNULL(@tmpValue, 0)
			else
				SET @result = 0
		end
		else
		begin
			if @tmpDateTime > @FromDate and @tmpDateTime < @ToDate
				set @result = ISNULL(@tmpValue, 0)
			else
				SET @result =0
		end
    END
	else if @Type = 19
	begin
		select top(1) @result = RealSalary
		from HR_EmpBasicSalary with (nolock)
		where EmployeeID = @EmployeeCode and EffectDate <= @ToTime
		order by EffectDate desc
	end
	else if @Type = 20
	begin
		;WITH LData AS (
			SELECT RTRIM(LTRIM(data)) AS Code FROM HR_FNSplitString_varchar(@Expression, '+')
		)
		select @result = sum(RealSalary + FixAmount)/12.0
		from (
			select DowCode, AVG(RealSalary_BS) as RealSalary
			from HR_PRListOfEmpSalary with (nolock)
			where EmployeeID = @EmployeeCode and left(DowCode, 4) = @Year
			group by DowCode
		) as R left join (
			select DowCode, sum(FixAmount) as FixAmount
			from (
				select DowCode, AlloGradeCode, AVG(FixAmount) as FixAmount
				from HR_PRListOfEmpAllowance as N with (nolock) 
					inner join LData as N1 on N.AllogradeCode = N1.Code
				where EmployeeID = @EmployeeCode and left(DowCode, 4) = @Year
				group by DowCode, AlloGradeCode
			) as Z Group By DowCode
		) as R1 on R.DowCode = R1.DowCode
	END
    else if @Type = 21
	BEGIN
		;WITH LData AS (
			SELECT RTRIM(LTRIM(data)) AS Code FROM HR_FNSplitString_varchar(@Expression, '+')
		)
		SELECT @result = sum(FixAmount)
		from (
			select DowCode, AlloGradeCode, FixAmount, 
				ROW_NUMBER() OVER(PARTITION BY DowCode, AlloGradeCode ORDER BY N.FromTime desc) as RowID
			from HR_PRListOfEmpAllowance as N with (nolock) 
				inner join LData as N1 on N.AllogradeCode = N1.Code
			where EmployeeID = @EmployeeCode and left(DowCode, 4) = @Year
		) as Z
		WHERE Z.RowID = 1

    END
    else if @Type = 22
	BEGIN
		SELECT @result = sum(RealSalary_BS)
		from (
			select DowCode, N.RealSalary_BS, 
				ROW_NUMBER() OVER(PARTITION BY DowCode ORDER BY N.FromTime desc) as RowID
			from HR_PRListOfEmpSalary as N with (nolock) 
			where EmployeeID = @EmployeeCode and left(DowCode, 4) = @Year
		) as Z
		WHERE Z.RowID = 1
    END
	else if @Type = 23
	BEGIN
		SELECT @result = sum(DowNum)
		from (
			select DowCode, N.DowNum, 
				ROW_NUMBER() OVER(PARTITION BY DowCode ORDER BY N.FromTime desc) as RowID
			from dbo.HR_PayIncome as N with (nolock) 
			where EmployeeID = @EmployeeCode and left(DowCode, 4) = @Year
		) as Z
		WHERE Z.RowID = 1

    END
	else if @Type = 24
	BEGIN
		SELECT @FromDate = MIN(FromDate), @ToTime = MAX(ToDate)
		FROM dbo.HR_ConfigTSEmpStandardWD WITH (NOLOCK)
		WHERE EmployeeID = @EmployeeCode AND LEFT(DowCode, 4) = @Year

		SELECT TOP(1) @tmpDateTime = JoinedOn FROM dbo.HR_Employees WITH (NOLOCK) WHERE EmployeeID = @EmployeeCode

		/*
			Nếu nhân viên nào vào làm <=20/12/2023 (bắt đầu kỳ công tháng 01/2024) thì sẽ bằng tổng tất cả các ngày công chuẩn thực tế trong năm của nhân viên
			or nhân vien vào làm tháng đầu tiên
		*/
		IF @tmpDateTime <= @FromDate OR @tmpDateTime BETWEEN @FromDate AND (DATEADD(MONTH, 1, @FromDate) - 1)
		BEGIN
			SELECT @result = sum(DowNum)
			from (
				select DowCode, N.DowNum, 
					ROW_NUMBER() OVER(PARTITION BY DowCode ORDER BY N.FromTime desc) as RowID
				from dbo.HR_PayIncome as N with (nolock) 
				where EmployeeID = @EmployeeCode and left(DowCode, 4) = @Year
			) as Z
			WHERE Z.RowID = 1
        END
		ELSE
        BEGIN
			SELECT TOP(1) @strValue = GroupSalCode
			FROM dbo.HR_PayIncome WITH (NOLOCK) WHERE EmployeeID = @EmployeeCode
			ORDER BY DowCode

			set @tmpValue = 0
			SELECT @tmpValue = COUNT(1)
			FROM (
				SELECT RTRIM(LTRIM(data)) AS Code FROM HR_FNSplitString_varchar('StaffL_7LD2 + StaffL_7LD', '+')
			) AS R WHERE R.Code = @strValue

			IF @tmpValue > 0
			BEGIN
				;WITH LData AS (
					SELECT RTRIM(LTRIM(data)) AS Code FROM HR_FNSplitString_varchar('StaffL_7LD2 + StaffL_7LD', '+')
				)
				SELECT @result = SUM(R.StandardWD)
				FROM (
					SELECT T.DowCode, MIN(StandardWD) AS StandardWD
					FROM dbo.HR_ConfigTSSubStandardWD AS T WITH (NOLOCK) 
						INNER JOIN LData AS T1 ON T.ObjectCode = T1.Code
					WHERE T.ChangeObject = 2 AND @tmpDateTime > T.ToDate AND LEFT(T.DowCode, 4) = @Year
					GROUP BY T.DowCode
				) AS R
            END
			ELSE
			begin
				SELECT @result = SUM(R.StandardWD)
				FROM (
					SELECT T.DowCode, MIN(StandardWD) AS StandardWD
					FROM dbo.HR_ConfigTSSubStandardWD AS T WITH (NOLOCK) 
					WHERE T.ChangeObject = 2 AND @tmpDateTime > T.ToDate AND LEFT(T.DowCode, 4) = @Year and ObjectCode = @strValue
					GROUP BY T.DowCode
				) AS R
			end
			
			SELECT @result = @result + SUM(DowNum)
			from (
				select DowCode, N.DowNum, 
					ROW_NUMBER() OVER(PARTITION BY DowCode ORDER BY N.FromTime desc) as RowID
				from dbo.HR_PayIncome as N with (nolock) 
				where EmployeeID = @EmployeeCode AND @tmpDateTime <= N.ToTime AND LEFT(N.DowCode, 4) = @Year
			) as Z
			WHERE Z.RowID = 1

        END 
    END
	ELSE IF @Type = 25
	BEGIN
		SELECT @FromDate = MIN(FromDate), @ToDate = MAX(ToDate)
		FROM dbo.HR_ConfigTSEmpStandardWD WITH (NOLOCK)
		WHERE EmployeeID = @EmployeeCode AND LEFT(DowCode, 4) = @Year

		IF NOT EXISTS(SELECT TOP(1) 1 FROM dbo.HR_EmpTracking WITH (NOLOCK)
			WHERE EmployeeID = @EmployeeCode AND TableName = 'HR_Employees' AND FieldName = 'JobWCode')
		BEGIN
			SELECT TOP(1) @strValue = PositionID FROM dbo.HR_Employees WITH (NOLOCK) WHERE EmployeeID = @EmployeeCode	

			--select top(1) @tmpValue = isnull(CBI, 0) from HR_Positions with (nolock) where JobWCode = @strValue --Chưa có field CBI

			IF @tmpValue = 0
			begin
				SET @result = 0
			end
			ELSE
            BEGIN
				;WITH LData AS (
					SELECT RTRIM(LTRIM(data)) AS Code FROM HR_FNSplitString_varchar(@Expression, '+')
				)
				SELECT @result = SUM(T.DayNum)
				FROM dbo.HR_TSKowDs AS T WITH (NOLOCK) INNER JOIN LData AS T1 ON T.KowCode = T1.Code
				WHERE T.EmployeeID = @EmployeeCode AND T.WorkDate BETWEEN @FromDate AND @ToDate
            end
        END 
		ELSE
        BEGIN
			DECLARE @EffectDate DATETIME, @Value VARCHAR(20), @ValueOld VARCHAR(20)
			DECLARE @tmpFromTime_OLD DATETIME, @tmpFromTime DATETIME, @tmpToTime DATETIME
			
			SET @tmpFromTime_OLD = @FromDate
			SET @result = 0
			DECLARE cursor_1 CURSOR FOR  
				WITH tblTmp AS (
					SELECT EffectDate, Value, ValueOld FROM HR_EmpTracking WITH (NOLOCK)
					WHERE EmployeeID = @EmployeeCode AND TableName = 'HR_Employees' AND FieldName = 'JobWCode'
						AND EffectDate >= @FromDate
				)
				SELECT EffectDate, [Value], ValueOld FROM tblTmp ORDER BY EffectDate
			OPEN cursor_1
			WHILE 1 = 1  
			BEGIN   
				FETCH NEXT FROM cursor_1 INTO @EffectDate, @Value, @ValueOld
				IF @@FETCH_STATUS != 0
					BREAK;
				
				IF @EffectDate <> @FromDate
				BEGIN
					SET @tmpFromTime = @tmpFromTime_OLD
					SET @tmpToTime = @EffectDate - 1
					SET @tmpFromTime_OLD = @EffectDate

					--select top(1) @tmpValue = isnull(CBI, 0) from HR_Positions with (nolock) where JobWCode = @ValueOld
					
					IF @tmpValue = 1
					BEGIN
						;WITH LData AS (
							SELECT RTRIM(LTRIM(data)) AS Code FROM HR_FNSplitString_varchar(@Expression, '+')
						)
						SELECT @result = @result + SUM(T.DayNum)
						FROM dbo.HR_TSKowDs AS T WITH (NOLOCK) INNER JOIN LData AS T1 ON T.KowCode = T1.Code
						WHERE T.EmployeeID = @EmployeeCode AND T.WorkDate BETWEEN @tmpFromTime AND @tmpToTime

                    END 
                END 
			END
			CLOSE cursor_1   
			DEALLOCATE cursor_1

			IF @EffectDate BETWEEN @FromDate AND @ToDate
			BEGIN
				SET @tmpFromTime = @EffectDate
				SET @tmpToTime = @ToDate

				--select top(1) @tmpValue = isnull(CBI, 0) from HR_Positions with (nolock) where JobWCode = @Value
					
				IF @tmpValue = 1
				BEGIN
					;WITH LData AS (
						SELECT RTRIM(LTRIM(data)) AS Code FROM HR_FNSplitString_varchar(@Expression, '+')
					)
					SELECT @result = @result + SUM(T.DayNum)
					FROM dbo.HR_TSKowDs AS T WITH (NOLOCK) INNER JOIN LData AS T1 ON T.KowCode = T1.Code
					WHERE T.EmployeeID = @EmployeeCode AND T.WorkDate BETWEEN @tmpFromTime AND @tmpToTime

                END 
            END
        END 
		
		

		SET @result = ISNULL(@result, 0)
	END 


	SET @result = ISNULL(@result, 0)
	return @result

END


---------------------------------------2
USE [codx_hr]
GO
/****** Object:  UserDefinedFunction [dbo].[HR_fnFGetHT_LayThongTinLuongBatKyV2]    Script Date: 2/7/2025 6:29:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER FUNCTION [dbo].[HR_fnFGetHT_LayThongTinLuongBatKyV2](
	@EmployeeCode NVARCHAR(20),
	@DowCode VARCHAR(7),
	@ToTime datetime,
	@Expression VARCHAR(max),
	@Type int
)
RETURNS DATETIME
AS
BEGIN
	
	DECLARE @result DATETIME, @FromDate DATETIME, @ToDate DATETIME, @tmpValue float
	SET @result = 0
	SET @Expression = LTRIM(RTRIM(@Expression))

	-- Tìm kỳ lương
	SELECT TOP(1) @DowCode = DowCode, @FromDate = FromDate, @ToDate = ToDate 
	FROM dbo.HR_ConfigTSEmpStandardWD WITH (NOLOCK) 
	WHERE EmployeeID = @EmployeeCode AND FromDate < @ToTime
	ORDER BY FromDate desc
	
	IF @Type = 1 -- Ngày bắt đầu QĐ lương 1
	BEGIN
		SELECT TOP(1) @result = R.FromTime
		FROM (
			SELECT ROW_NUMBER() OVER(ORDER BY FromTime) as RowID, FromTime 
			FROM dbo.HR_PRListOfEmpSalary WITH (NOLOCK) where EmployeeID = @EmployeeCode AND DowCode = @DowCode
		) AS R WHERE R.RowID = 1
    END
    ELSE IF @Type = 2 -- Ngày kết thúc QĐ lương 1
	BEGIN
		SELECT TOP(1) @result = R.ToTime
		FROM (
			SELECT ROW_NUMBER() OVER(ORDER BY FromTime) as RowID, ToTime 
			FROM dbo.HR_PRListOfEmpSalary WITH (NOLOCK) where EmployeeID = @EmployeeCode AND DowCode = @DowCode
		) AS R WHERE R.RowID = 1
    END
	ELSE IF @Type = 3 -- Ngày bắt đầu QĐ PC 1
	BEGIN
		SELECT TOP(1) @result = R.FromTime
		FROM (
			SELECT ROW_NUMBER() OVER(ORDER BY FromTime) as RowID, FromTime 
			FROM dbo.HR_PRListOfEmpAllowance WITH (NOLOCK)
			WHERE EmployeeID = @EmployeeCode AND DowCode = @DowCode AND AlloGradeCode = @Expression
		) AS R WHERE R.RowID = 1
    END
	ELSE IF @Type = 4 -- Ngày kết thúc QĐ PC 1
	BEGIN
		SELECT TOP(1) @result = R.ToTime
		FROM (
			SELECT ROW_NUMBER() OVER(ORDER BY FromTime) as RowID, ToTime 
			FROM dbo.HR_PRListOfEmpAllowance WITH (NOLOCK)
			WHERE EmployeeID = @EmployeeCode AND DowCode = @DowCode AND AlloGradeCode = @Expression
		) AS R WHERE R.RowID = 1
    END
	ELSE IF @Type = 5 -- Ngày bắt đầu QĐ lương 2
	BEGIN
		SELECT TOP(1) @result = R.FromTime
		FROM (
			SELECT ROW_NUMBER() OVER(ORDER BY FromTime) as RowID, FromTime 
			FROM dbo.HR_PRListOfEmpSalary WITH (NOLOCK) where EmployeeID = @EmployeeCode AND DowCode = @DowCode
		) AS R WHERE R.RowID = 2
    END
    ELSE IF @Type = 6 -- Ngày kết thúc QĐ lương 2
	BEGIN
		SELECT TOP(1) @result = R.ToTime
		FROM (
			SELECT ROW_NUMBER() OVER(ORDER BY FromTime) as RowID, ToTime 
			FROM dbo.HR_PRListOfEmpSalary WITH (NOLOCK) where EmployeeID = @EmployeeCode AND DowCode = @DowCode
		) AS R WHERE R.RowID = 2
    END
	ELSE IF @Type = 7 -- Ngày bắt đầu QĐ PC 2
	BEGIN
		SELECT TOP(1) @result = R.FromTime
		FROM (
			SELECT ROW_NUMBER() OVER(ORDER BY FromTime) as RowID, FromTime 
			FROM dbo.HR_PRListOfEmpAllowance WITH (NOLOCK)
			WHERE EmployeeID = @EmployeeCode AND DowCode = @DowCode AND AlloGradeCode = @Expression
		) AS R WHERE R.RowID = 2
    END
	ELSE IF @Type = 8 -- Ngày kết thúc QĐ PC 2
	BEGIN
		SELECT TOP(1) @result = R.ToTime
		FROM (
			SELECT ROW_NUMBER() OVER(ORDER BY FromTime) as RowID, ToTime 
			FROM dbo.HR_PRListOfEmpAllowance WITH (NOLOCK)
			WHERE EmployeeID = @EmployeeCode AND DowCode = @DowCode AND AlloGradeCode = @Expression
		) AS R WHERE R.RowID = 2
    END
	ELSE IF @Type = 9
	begin
	
		;with tblAlloGrade as (
			select B.AlloGradeCode, B.IsFixAmount from HR_FNSplitString_varchar(@Expression, '+') as A inner join HR_LSAlloGrade as B on ltrim(rtrim(A.[data])) = B.AlloGradeCode
		)
		select top(1) @result = EndDate
		from (
			select AG.AlloGradeCode as ID, EndDate,
				ROW_NUMBER() OVER(PARTITION BY AG.AlloGradeCode ORDER BY EffectDate desc) as Row_ID
			from HR_EmpAllowance as A with (nolock) inner join tblAlloGrade as AG WITH (NOLOCK) on A.AlloGradeCode = AG.AlloGradeCode
			where EmployeeID = @EmployeeCode and 
				(EffectDate <= @ToTime and (EndDate = '' OR EndDate IS NULL OR EndDate > @ToTime))
		) as R where Row_ID = 1

	END
    ELSE IF @Type = 10
	BEGIN
		SELECT TOP(1) @result = FromDate 
		FROM dbo.HR_ConfigTSEmpStandardWD WITH (NOLOCK) 
		WHERE EmployeeID = @EmployeeCode AND DowCode < @DowCode
		ORDER BY FromDate desc
    END
    ELSE IF @Type = 11
	BEGIN
		SELECT TOP(1) @result = ToDate 
		FROM dbo.HR_ConfigTSEmpStandardWD WITH (NOLOCK) 
		WHERE EmployeeID = @EmployeeCode AND DowCode < @DowCode
		ORDER BY FromDate desc
    END
    ELSE IF @Type = 12
	BEGIN
		SELECT TOP(1) @tmpValue = CalDate
		FROM dbo.HR_LSException
		WHERE ExceptCode = @Expression

		IF ISNULL(@tmpValue, 0) <> 0
			SET @result = CONVERT(VARCHAR(7), @ToTime, 111) + '/' + CAST(@tmpValue AS varchar)
		ELSE
			SET @result = @ToTime

    end
    

	return @result

END


------------------3
USE [codx_hr]
GO
/****** Object:  UserDefinedFunction [dbo].[HR_fnFGetHT_LayThongTinLuongBatKyV3]    Script Date: 2/7/2025 6:30:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER FUNCTION [dbo].[HR_fnFGetHT_LayThongTinLuongBatKyV3](
	@EmployeeCode NVARCHAR(20),
	@DowCode VARCHAR(7),
	@Year int,
	@FixDay int,
	@Expression VARCHAR(max),
	@Type int
)
RETURNS float
AS
BEGIN
	
	declare @result float, @ToTime datetime

	if @FixDay = 0
	begin
		set @ToTime = cast(@year as varchar) + '/12/31'
	end
	else
	begin
		if ISDATE(cast(@year as varchar) + '/12' + '/' + cast(@FixDay as varchar)) = 1
			set @ToTime = cast(@year as varchar) + '/12' + '/' + cast(@FixDay as varchar)
		else
			set @ToTime = cast(@year as varchar) + '/12/31'
	end

	if @Type = 1
	begin
		select top(1) @result = RealSalary
		from HR_EmpBasicSalary where EmployeeID = @EmployeeCode and EffectDate <= @ToTime
		order by EffectDate desc
	end

	SET @result = ISNULL(@result, 0)
	return @result

END


-----------------4
USE [codx_hr]
GO
/****** Object:  UserDefinedFunction [dbo].[HR_fnGetItemEmpTracking]    Script Date: 2/7/2025 6:30:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER function [dbo].[HR_fnGetItemEmpTracking]
(
	@EmployeeCode NVARCHAR(20) = 'hphoa',
	@Item VARCHAR(MAX),
	@ToTime datetime
)
RETURNS @t TABLE(fDate DATETIME, tDate DATETIME, fBeginDate datetime, fEndDate datetime, 
				DepartmentCode NVARCHAR(20), GroupSalCode VARCHAR(20), JobWCode VARCHAR(20), JobPosCode VARCHAR(20), EmpTypeCode VARCHAR(20), LabourType INT,
				WorkCenterCode VARCHAR(20))
AS
BEGIN
	DECLARE @fBeginDate DATETIME, @fEndDate DATETIME, @maxCurrDate DATETIME, @mToTime datetime, @mFromTime datetime
	DECLARE @idx INT, @EffectDate datetime
	DECLARE @DepartmentCode NVARCHAR(20), @GroupSalCode VARCHAR(20), @JobWCode VARCHAR(20), @JobPosCode VARCHAR(20), @EmpTypeCode VARCHAR(20), @LabourType INT, @WorkCenterCode VARCHAR(20)
	DECLARE @JoinDate DATETIME

	SET @fBeginDate = @ToTime
	SET @fEndDate = @ToTime
	
	DECLARE @tbl_Emps TABLE(EmployeeCode NVARCHAR(20), DepartmentCode NVARCHAR(20), GroupSalCode VARCHAR(20), JobWCode VARCHAR(20), JobPosCode VARCHAR(20), EmpTypeCode VARCHAR(20), LabourType int, JoinDate datetime, FromTime datetime, ToTime DATETIME, WorkCenterCode VARCHAR(20))
	DECLARE @tbl_mFields TABLE(data varchar(50))
	
	-- Table chứa danh sách nhân viên cần xét.
	insert into @tbl_Emps 
	select A.EmployeeCode, E.OrgUnitID, E.GroupSalCode, E.JobLevel, E.PositionID, E.EmpTypeCode, E.LabourType, E.JoinedOn, FromTime, ToTime, E.WorkCenterCode
	from (
		select @EmployeeCode as EmployeeCode, @fBeginDate as FromTime, @fEndDate as ToTime
	) as A left outer join HR_VWEmployeeGeneralInfo as E with (nolock) on A.EmployeeCode = E.EmployeeID 
	OPTION(MAXRECURSION 0)

	SELECT TOP(1) @JoinDate = JoinedOn FROM HR_Employees WITH (NOLOCK) WHERE EmployeeID = @EmployeeCode

	-- Table chứa danh sách các fields cần xét.
	insert into @tbl_mFields select data from HR_FNSplitString(@Item, ',')


	-- Nếu App_IsSolar_CalSalaryLevel = 1 --> lấy theo dương lịch, ngược lại, lấy theo kỳ tính lương
	DECLARE employee_cursor CURSOR FOR  
		WITH tblEmpTracking AS (
			SELECT A1.TableName, A1.FieldName, A1.EffectDate, A1.Value, A1.ValueOld, A1.CreatedOn
			FROM (
				SELECT T.TableName, T.FieldName, T.EffectDate, T.Value, T.ValueOld, T.CreatedOn
				FROM dbo.HR_EmpTracking as T with (nolock) inner join @tbl_Emps as E on T.EmployeeID = E.EmployeeCode	
				inner join (
					-- Danh sách column cần tách phiếu lương
					select TableName, FieldName FROM HR_SysTrackingValue as TV with (nolock) inner join @tbl_mFields as mFields on TV.FieldName = mFields.data 
					WHERE IsTracking = 1 --and IsSplit = 1
				) as R on T.TableName = R.TableName and T.FieldName = R.FieldName
			) AS A1
		), tblTrackingInFuture as (
			-- Lấy những nhân viên có khai báo bắt đầu tracking xảy ra trong tương lai.
			select TableName, FieldName, ValueOld as Value, ValueOld, EffectDate, FromTime, ToTime
			from (
				select T.TableName, T.FieldName, Value, ValueOld, CASE when @fBeginDate < @JoinDate THEN @JoinDate ELSE @fBeginDate end as EffectDate, 
					@fBeginDate as FromTime, @fEndDate as ToTime,
					T.EffectDate as mEffectDate,
					ROW_NUMBER() OVER(PARTITION BY T.TableName, T.FieldName, EffectDate ORDER BY EffectDate asc, T.CreatedOn asc) as Row_ID
				FROM tblEmpTracking AS T
			) as X where Row_ID = 1 and mEffectDate > @fEndDate
		), ETracking as (
			-- Danh sách các field cần tracking để tách phiếu lương.
			select T.TableName, T.FieldName, Value, ValueOld, EffectDate, @fBeginDate as FromTime, @fEndDate as ToTime, T.CreatedOn
			from tblEmpTracking AS T
			where T.EffectDate <= @fEndDate
		), ATracking as (
			-- Danh sách các field cần tracking để tách phiếu lương.
			SELECT @EmployeeCode AS EmployeeCode, A1.TableName, A1.FieldName, A1.EffectDate, A1.Value, A1.ValueOld, A1.CreatedOn
			FROM (
				SELECT T.TableName, T.FieldName, T.EffectDate, T.Value, T.ValueOld, T.CreatedOn
				FROM dbo.HR_EmpTracking as T with (nolock) inner join @tbl_Emps as E on T.EmployeeID = E.EmployeeCode	
				inner join (
					-- Danh sách column cần tách phiếu lương
					select TableName, FieldName FROM HR_SysTrackingValue as TV with (nolock) inner join @tbl_mFields as mFields on TV.FieldName = mFields.data 
					WHERE IsTracking = 1 --and IsSplit = 1
				) as R on T.TableName = R.TableName and T.FieldName = R.FieldName
			) AS A1
			where EffectDate <= @fEndDate
		), tblResult as (
			select ETracking.TableName, ETracking.FieldName, Value, ValueOld, tmp_EffectDate, EffectDate, FromTime, ToTime
			from (
				-- Danh sách column có dữ liệu thay đổi trong khoảng thời gian @FromTime to @ToTime
				select TableName, FieldName, Value, ValueOld, tmp_EffectDate, EffectDate, FromTime, ToTime
				from (
					select TableName, FieldName, Value, ValueOld, EffectDate as tmp_EffectDate,
						ROW_NUMBER() OVER(PARTITION BY TableName, FieldName, EffectDate ORDER BY EffectDate desc, ETracking.CreatedOn desc) as Row_ID,
						case when EffectDate <= FromTime then FromTime else EffectDate end EffectDate, FromTime, ToTime
					from ETracking where EffectDate between FromTime and ToTime
				) as R where Row_ID = 1
				union all
				-- Danh sach column co dữ liệu thay đổi trong khoảng thời gian trước @FromTime.
				select TableName, FieldName, Value, ValueOld, tmp_EffectDate, EffectDate, FromTime, ToTime
				from (
					select TableName, FieldName, Value, ValueOld, EffectDate as tmp_EffectDate,
						ROW_NUMBER() OVER(PARTITION BY TableName, FieldName ORDER BY EffectDate desc, ETracking.CreatedOn desc) as Row_ID,
						case when EffectDate <= FromTime then FromTime else EffectDate end EffectDate, FromTime, ToTime
					from ETracking where EffectDate < FromTime
				) as R where Row_ID = 1
				union all
				select TableName, FieldName, Value, ValueOld, EffectDate as tmp_EffectDate, EffectDate, FromTime, ToTime from tblTrackingInFuture
			) as ETracking
		), tblEmployeeTrackingNotData as (
			SELECT [DepartmentCode], [GroupSalCode], [JobWCode], [JobPosCode], [EmpTypeCode], [LabourType], 
					Z.EffectDate as EffectDate, 
					Z.FromTime as FromTime, 
					Z.ToTime AS ToTime, [WorkCenterCode]
			FROM (
				select PT.EmployeeCode, R.[DepartmentCode], R.[GroupSalCode], R.[JobWCode], R.[JobPosCode], R.[EmpTypeCode], R.[LabourType], 
					case when R.JoinDate < @fBeginDate then @fBeginDate else R.JoinDate end as EffectDate, 
					case when R.JoinDate < @fBeginDate then @fBeginDate else R.JoinDate end as FromTime, @fEndDate as ToTime,
					R.[WorkCenterCode]
				from (
					-- Nhan vien không tồn tại dữ liệu trong bảng tracking.
					select F.EmployeeCode, F.FieldName, cast(null as NVARCHAR(20)) as Value
					from (
						select EmployeeCode, data as FieldName from @tbl_Emps cross join @tbl_mFields as mFields
					) as F left outer join ATracking as E on F.EmployeeCode = E.EmployeeCode and F.FieldName = E.FieldName where E.FieldName is null	
				) AS X 
					PIVOT( max(Value) FOR FieldName IN ([DepartmentCode], [GroupSalCode], [JobWCode], [JobPosCode], [EmpTypeCode], [LabourType], [WorkCenterCode]) 
				) AS PT left outer join @tbl_Emps as R on PT.EmployeeCode = R.EmployeeCode
			) AS Z 
		)
		-- Lay ve danh sach nhan vien co luong lcb va lcd theo yc
		SELECT RE.EffectDate, FromTime, ToTime, DepartmentCode, GroupSalCode, JobWCode, JobPosCode, EmpTypeCode, LabourType, WorkCenterCode
		FROM
		(
			select 
				isnull(R1.tmp_EffectDate, R2.tmp_EffectDate) as tmp_EffectDate,
				isnull(R1.EffectDate, R2.EffectDate) as EffectDate,
				isnull(R1.[DepartmentCode], R2.[DepartmentCode]) as [DepartmentCode],
				isnull(R1.[GroupSalCode], R2.[GroupSalCode]) as [GroupSalCode],
				isnull(R1.[JobWCode], R2.[JobWCode]) as [JobWCode],
				isnull(R1.[JobPosCode], R2.[JobPosCode]) as [JobPosCode],
				isnull(R1.[EmpTypeCode], R2.[EmpTypeCode]) as [EmpTypeCode],
				isnull(R1.[LabourType], R2.[LabourType]) as [LabourType],
				isnull(R1.FromTime, R2.FromTime) as FromTime,
				isnull(R1.ToTime, R2.ToTime) as ToTime,
				ISNULL(R1.[WorkCenterCode], R2.[WorkCenterCode]) AS [WorkCenterCode]
			from (
				SELECT EffectDate as tmp_EffectDate, EffectDate, [DepartmentCode], [GroupSalCode] AS [GroupSalCode], [JobWCode], [JobPosCode], [EmpTypeCode], [LabourType], 
					FromTime, ToTime, WorkCenterCode
				FROM
				(
					select FieldName, cast(Value as NVARCHAR(20)) as Value, EffectDate, FromTime, ToTime
					from (
						select ETracking.FieldName, Value, EffectDate, FromTime, ToTime
						from tblResult as ETracking
						union all
						select FieldName, ValueOld, @fBeginDate as EffectDate, FromTime, ToTime
						from (
							select FieldName, ValueOld, EffectDate, FromTime, ToTime, 
								ROW_NUMBER() OVER(PARTITION BY TableName, FieldName ORDER BY EffectDate asc) as Row_ID
							from tblResult
						) as T where Row_ID = 1 and EffectDate > @fBeginDate
					) as R
				) AS R
				PIVOT(
					max(Value) FOR FieldName IN ([DepartmentCode], [GroupSalCode], [JobWCode], [JobPosCode], [EmpTypeCode], [LabourType], [WorkCenterCode])
				) AS PT
			) as R1
			full outer join
			(
				select EffectDate as tmp_EffectDate, EffectDate, [DepartmentCode], [GroupSalCode], [JobWCode], [JobPosCode], [EmpTypeCode], [LabourType], 
					FromTime, ToTime, WorkCenterCode
				from tblEmployeeTrackingNotData
			) as R2 on R1.EffectDate = R2.EffectDate
		) as RE
		ORDER BY EffectDate DESC, tmp_EffectDate DESC
		OPTION (MAXRECURSION 0)
	OPEN employee_cursor

	WHILE 1 = 1  
	BEGIN   
		FETCH NEXT FROM employee_cursor INTO @EffectDate, @mFromTime, @mToTime,
											@DepartmentCode, @GroupSalCode, @JobWCode, @JobPosCode, @EmpTypeCode, @LabourType, @WorkCenterCode
		IF @@FETCH_STATUS != 0
			BREAK;

		SET @idx = 0
		SET @maxCurrDate = @mToTime

		IF DATEDIFF(day, @mFromTime, @EffectDate) >= 0 And DATEDIFF(day, @EffectDate, @maxCurrDate) >= 0 AND @EffectDate >= @JoinDate
		BEGIN
			INSERT INTO @t VALUES(@EffectDate, @maxCurrDate, @mFromTime, @mToTime,
						@DepartmentCode, @GroupSalCode, @JobWCode, @JobPosCode, @EmpTypeCode, @LabourType, @WorkCenterCode)
			SET @maxCurrDate = DateAdd(day, -1, @EffectDate)
		END
		ELSE
		BEGIN
			IF @idx > 0 And Datediff(day, @mFromTime, @maxCurrDate) >= 0 AND @EffectDate >= @JoinDate
				INSERT INTO @t VALUES(@mFromTime, @maxCurrDate, @mFromTime, @mToTime,
						@DepartmentCode, @GroupSalCode, @JobWCode, @JobPosCode, @EmpTypeCode, @LabourType, @WorkCenterCode)
			IF @idx = 0  AND @EffectDate >= @JoinDate
				INSERT INTO @t VALUES(@mFromTime, @maxCurrDate, @mFromTime, @mToTime,
						@DepartmentCode, @GroupSalCode, @JobWCode, @JobPosCode, @EmpTypeCode, @LabourType, @WorkCenterCode)
		END
	END

	CLOSE employee_cursor  	
	DEALLOCATE employee_cursor
	RETURN
END


--------------------5
USE [codx_hr]
GO
/****** Object:  UserDefinedFunction [dbo].[HR_fnFGetHT_LayThongTinBatKy]    Script Date: 2/7/2025 6:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER FUNCTION [dbo].[HR_fnFGetHT_LayThongTinBatKy](
	@EmployeeCode NVARCHAR(20) = 'ELV01016',
	@DowCode VARCHAR(7) = '2019/01',
	@ToTime datetime = '2018/12/24',
	@Expression varchar(max) = 'AG_KPI+AG_TN+AG_CVU+AG_TNIEN+AG_KN',
	@Type int = 16
)
RETURNS float
AS
BEGIN
	declare @result float, @DepartmentCode nvarchar(20), @GroupSalCode varchar(20), @SalaryUnit float, @fBegDay datetime, @fEndDay DATETIME
    DECLARE @JoinDate DATETIME, @EndDate DATETIME, @tmpValue FLOAT
	DECLARE @DayLock INT, @DateLock DATETIME
	declare @tsBegDate datetime, @tsEndDate datetime, @tmpBegDate datetime, @tmpEndDate DATETIME
    DECLARE @iMonth INT, @AprRankCode VARCHAR(20), @iYear INT, @tmpString VARCHAR(20), @GroupCode varchar(20)

	SET @iYear = YEAR(@ToTime)
	SET @Expression = LTRIM(RTRIM(@Expression))

	IF @Type = 1
	BEGIN
		-- Lấy giá trị mặc định của hệ số lương thưởng
		;WITH LData AS (
			SELECT RTRIM(LTRIM(data)) AS Code FROM HR_FNSplitString_varchar(@Expression, '+')
		)
		SELECT @result = SUM(T.DefaultValue)
		FROM HR_LSSalCoeff as T WITH (NOLOCK) INNER JOIN LData AS T1 ON T.CoeffCode = T1.Code
    END
    ELSE IF @Type = 2
	BEGIN

		select top(1) @DowCode = DowCode from HR_LSPayrollDow where BegDay <= @ToTime order by DowCode desc

		-- Lay gia tri thu nhap khac trong TExcepts
		;WITH LData AS (
			SELECT RTRIM(LTRIM(data)) AS Code FROM HR_FNSplitString_varchar(@Expression, '+')
		)
		SELECT @result = SUM(T.Amount)
		FROM HR_PayTExcept as T WITH (NOLOCK) INNER JOIN LData AS T1 ON T.ExceptCode = T1.Code
		WHERE T.EmployeeID = @EmployeeCode AND DowCode = @DowCode
	END
    ELSE IF @Type = 3
	BEGIN
		IF EXISTS(SELECT TOP(1) 1 FROM HR_SocialIns WITH (NOLOCK) WHERE DowCode = @DowCode AND EmployeeID = @EmployeeCode)
			SET @result = 1
		ELSE
			SET @result = 0
	END
	ELSE IF @Type = 4
	BEGIN
		select top(1) @DowCode = DowCode from HR_LSPayrollDow where BegDay <= @ToTime order by DowCode desc

		select top(1) @DepartmentCode =  dbo.HR_fnGetFirstDepartmentIsFund(OrgUnitID), @GroupSalCode = GroupSalCode 
		from HR_PRSalCoeffEmp 
		where EmployeeID = @EmployeeCode and DowCode = @DowCode

		select @result = sum(SalaryUnit) 
		from HR_PRFundSalaryUnit with (nolock)
		where DowCode = @DowCode and OrgUnitID = @DepartmentCode and GroupSalCode = @GroupSalCode
	END
	ELSE IF @Type = 5
	BEGIN
		select top(1) @fBegDay = FromDate, @fEndDay = ToDate from HR_ConfigTSEmpStandardWD where DowCode = @DowCode and EmployeeID = @EmployeeCode

		;with tblAlloGrade as (
			select B.AlloGradeCode, B.IsFixAmount from HR_FNSplitString_varchar(@Expression, '+') as A inner join HR_LSAlloGrade as B on ltrim(rtrim(A.[data])) = B.AlloGradeCode
		)
		select @result = sum(Amount)
		from (
			select AG.AlloGradeCode as ID, case when AG.IsFixAmount = 1 then A.FixAmount else A.SalaryRate end as Amount,
				ROW_NUMBER() OVER(PARTITION BY AG.AlloGradeCode ORDER BY EffectDate desc) as Row_ID
			from HR_EmpAllowance as A with (nolock) inner join tblAlloGrade as AG WITH (NOLOCK) on A.AlloGradeCode = AG.AlloGradeCode
			where EmployeeID = @EmployeeCode and 
				(EffectDate <= @fEndDay and (EndDate = '' OR EndDate IS NULL OR EndDate > @fBegDay))
		) as R where Row_ID = 1
	END
	ELSE IF @Type = 6
	BEGIN
		SELECT @result = sum(SIAmountE + HIAmountE + UIAmountE) FROM HR_SocialIns WITH (NOLOCK) WHERE DowCode = @DowCode AND EmployeeID = @EmployeeCode

	END
	ELSE IF @Type = 7
	BEGIN
		set @DowCode = convert(varchar(7), DATEADD(month, -1, cast(@DowCode + '/01' as datetime)), 111)
		
		select top(1) @result = StandardWD from HR_ConfigTSEmpStandardWD with (nolock) where DowCode = @DowCode and EmployeeID = @EmployeeCode
	END
	ELSE IF @Type = 8
	BEGIN
		SELECT TOP(1) @DowCode = DowCode FROM dbo.HR_ConfigTSEmpStandardWD WHERE EmployeeID = @EmployeeCode AND FromDate <= @ToTime ORDER BY FromDate desc
		SELECT @result = sum(SIAmountC + HIAmountC + UIAmountC) FROM HR_SocialIns WITH (NOLOCK) WHERE DowCode = @DowCode AND EmployeeID = @EmployeeCode

	END
	ELSE IF @Type = 9
	BEGIN
		select top(1) @DowCode = DowCode from HR_LSPayrollDow where BegDay <= @ToTime order by DowCode desc
		-- Lấy giá trị mặc định của hệ số lương thưởng
		;WITH LData AS (
			SELECT RTRIM(LTRIM(data)) AS Code FROM HR_FNSplitString_varchar(@Expression, '+')
		)
		SELECT @result = SUM(T.Coefficient)
		FROM HR_PRSalCoeffEmp as T WITH (NOLOCK) INNER JOIN LData AS T1 ON T.CoeffCode = T1.Code
		where T.DowCode = @DowCode and T.EmployeeID = @EmployeeCode
    END
	ELSE IF @Type = 10
	BEGIN
		select top(1) @DowCode = DowCode from HR_LSPayrollDow where BegDay <= @ToTime order by DowCode DESC
        
		SELECT @result = SUM(T.NetSalVND)
		FROM HR_PayIncome as T WITH (NOLOCK) 
		where T.DowCode = @DowCode and T.EmployeeID = @EmployeeCode
    END
	--ELSE IF @Type = 11
	--BEGIN
	--	select top(1) @DowCode = DowCode from HR_LSPayrollDow where BegDay <= @ToTime order by DowCode DESC
        
	--	DECLARE @JobWSalary11 MONEY, @DepartmentCode11 NVARCHAR(20), @TotalJobWSalary11 MONEY, @TotalHCSPR_SalCoeffDept FLOAT,
	--		@TotalHR_PRSalCoeffEmp FLOAT

	--	SELECT @JobWSalary11 = T.JobWSalary, @DepartmentCode11 = T.DepartmentCode
	--	FROM HR_PayIncome AS T WITH (NOLOCK)
	--	WHERE T.DowCode = T.DowCode AND T.EmployeeCode = @EmployeeCode
	--	ORDER BY T.FromTime DESC
        
	--	SELECT @TotalJobWSalary11 = SUM(R.JobWSalary)
	--	FROM (
	--		SELECT T.EmployeeCode, T.JobWSalary, ROW_NUMBER() OVER(PARTITION BY T.EmployeeCode ORDER BY T.FromTime desc) as RowID
	--		FROM HR_PayIncome AS T WITH (NOLOCK) INNER JOIN HR_FNGetChildDepartments(@DepartmentCode11) AS T1
	--			ON T.DepartmentCode = T1.DepartmentCode
	--		WHERE T.DowCode = @DowCode
	--	) AS R WHERE R.RowID = 1

	--	SELECT @TotalHCSPR_SalCoeffDept = SUM(T.Coefficient)
	--	FROM HCSPR_SalCoeffDept AS T WITH (NOLOCK) INNER JOIN HR_FNGetChildDepartments(@DepartmentCode11) AS T1
	--		ON T1.DepartmentCode = T.DepartmentCode
	--	WHERE DowCode = @DowCode

	--	;WITH tblSalcoeff AS (
	--		SELECT CAST(data AS VARCHAR(20)) AS CoeffCode FROM SplitStrings_CTE(@Expression, '+')
	--	)
	--	SELECT @TotalHR_PRSalCoeffEmp = SUM(T.Coefficient)
	--	FROM HR_PRSalCoeffEmp AS T WITH (NOLOCK) INNER JOIN HR_FNGetChildDepartments(@DepartmentCode11) AS T1
	--		ON T1.DepartmentCode = T.DepartmentCode
	--		INNER JOIN tblSalcoeff AS T2 ON T.CoeffCode = T2.CoeffCode
	--	WHERE DowCode = @DowCode AND T.EmployeeCode = @EmployeeCode

	--	IF ISNULL(@TotalJobWSalary11, 0) = 0
	--		SET @result = 0
	--	else
	--		SET @result = @JobWSalary11 / @TotalJobWSalary11 * @TotalHR_PRSalCoeffEmp * @TotalHCSPR_SalCoeffDept
		
 --   END
	ELSE IF @Type = 11
    BEGIN

            select top(1) @fBegDay = FromDate, @fEndDay = ToDate from HR_ConfigTSEmpStandardWD where ToDate < @ToTime and EmployeeID = @EmployeeCode order by FromDate desc

            ;with tblAlloGrade as (
                    select B.AlloGradeCode, B.IsFixAmount from HR_FNSplitString_varchar(@Expression, '+') as A inner join HR_LSAlloGrade as B on ltrim(rtrim(A.[data])) = B.AlloGradeCode
            )
            select @result = sum(Amount)
            from (
                    select AG.AlloGradeCode as ID, case when AG.IsFixAmount = 1 then A.FixAmount else A.SalaryRate end as Amount,
                        ROW_NUMBER() OVER(PARTITION BY AG.AlloGradeCode ORDER BY EffectDate desc) as Row_ID
                    from HR_EmpAllowance as A with (nolock) inner join tblAlloGrade as AG WITH (NOLOCK) on A.AlloGradeCode = AG.AlloGradeCode
                    where EmployeeID = @EmployeeCode and 
                        (EffectDate <= @fEndDay and (EndDate = '' OR EndDate IS NULL OR EndDate > @fBegDay))
            ) as R where Row_ID = 1
    END
    ELSE IF @Type = 12
    BEGIN

            select top(1) @fBegDay = FromDate, @fEndDay = ToDate from HR_ConfigTSEmpStandardWD where ToDate < @ToTime and EmployeeID = @EmployeeCode order by FromDate desc

            select @result = sum(RealSalary)
            from (
                    select RealSalary,
                        ROW_NUMBER() OVER(ORDER BY EffectDate desc) as Row_ID
                    from HR_EmpBasicSalary as A with (nolock)
                    where EmployeeID = @EmployeeCode and 
                        (EffectDate <= @fEndDay and (EndDate = '' OR EndDate IS NULL OR EndDate > @fBegDay))
            ) as R where Row_ID = 1
    END
	else if @Type = 13
	begin
		select top(1) @result = DowNum from HR_LSPayrollDow where BegDay <= @ToTime order by DowCode desc
	END
 --   else if @Type = 14
	--begin
	--	--select top(1) @result = Coeff from HR_JobLevels WITH (NOLOCK) where JobID = LTRIM(RTRIM(@Expression)) --Chưa chuyển cấu trúc bảng sang Codx nên chưa có field Coeff
	--END
    ELSE IF @Type = 15
    BEGIN
		set @DowCode = CONVERT(varchar(7), @ToTime, 111)
        select top(1) @fBegDay = FromDate, @fEndDay = ToDate from HR_ConfigTSEmpStandardWD where DowCode = @DowCode and EmployeeID = @EmployeeCode order by FromDate desc

        select @result = sum(RealSalary)
        from (
            select RealSalary,
                ROW_NUMBER() OVER(ORDER BY EffectDate desc) as Row_ID
            from HR_EmpBasicSalary as A with (nolock)
            where EmployeeID = @EmployeeCode and 
                (EffectDate <= @fEndDay and (EndDate = '' OR EndDate IS NULL OR EndDate > @fBegDay))
        ) as R where Row_ID = 1
    END
	ELSE IF @Type = 16
    BEGIN

		DECLARE @firstMonthOfYear VARCHAR(7)

		-- lacviet
       set @DowCode = CONVERT(varchar(7), @ToTime, 111)
       select top(1) @fBegDay = FromDate, @fEndDay = ToDate from HR_ConfigTSEmpStandardWD where DowCode = @DowCode and EmployeeID = @EmployeeCode order by FromDate desc
	   SET @firstMonthOfYear = LEFT(@DowCode, 4) + '/01'

	    ;with tblAlloGrade as (
            select B.AlloGradeCode, B.IsFixAmount
			FROM HR_FNSplitString_varchar(@Expression, '+') as A inner join HR_LSAlloGrade as B on ltrim(rtrim(A.[data])) = B.AlloGradeCode
        ), tblPrevEmpAllowance AS (
			SELECT EmployeeID, AlloGradeCode, EffectDate
			FROM (
				SELECT T2.EmployeeID, T2.AlloGradeCode, T2.EffectDate,
					ROW_NUMBER() OVER(PARTITION BY T2.EmployeeID, T2.AlloGradeCode ORDER BY EffectDate asc) as Row_ID 
				FROM HR_EmpAllowance AS T2 WITH (NOLOCK) INNER JOIN tblAlloGrade AS T3 ON T2.AlloGradeCode = T3.AlloGradeCode
				WHERE T2.EmployeeID = @EmployeeCode AND EffectDate < @fEndDay 
			) AS Z WHERE Z.Row_ID = 1
		), tblEmpAllowance AS (
			SELECT R.EmployeeID, R.AlloGradeCode, FixAmount, CASE WHEN R1.EffectDate IS NULL THEN R.EffectDate ELSE R1.EffectDate END AS EffectDate
			FROM (
				SELECT EmployeeID, AlloGradeCode, EffectDate, Z.FixAmount
				FROM (
					SELECT T2.EmployeeID, T2.AlloGradeCode, T2.FixAmount, T2.EffectDate,
						ROW_NUMBER() OVER(PARTITION BY T2.EmployeeID, T2.AlloGradeCode ORDER BY EffectDate desc) as Row_ID 
					FROM HR_EmpAllowance AS T2 WITH (NOLOCK) INNER JOIN tblAlloGrade AS T3 ON T2.AlloGradeCode = T3.AlloGradeCode
					WHERE T2.EmployeeID = @EmployeeCode AND (EffectDate <= @fEndDay and (EndDate = '' OR EndDate IS NULL OR EndDate > @fBegDay))
				) AS Z WHERE Z.Row_ID = 1
			) AS R LEFT JOIN tblPrevEmpAllowance AS R1 ON R.EmployeeID = R1.EmployeeID AND R.AlloGradeCode = R1.AlloGradeCode
		), tblThaiSan AS (
			SELECT *
			FROM (
				SELECT R.EmployeeID, R1.DowCode, ROW_NUMBER() OVER(PARTITION BY R.EmployeeID ORDER BY R1.DowCode desc) as Row_ID 
				FROM (
					SELECT TOP(1) T.EmployeeID, T.BeginDate, T.EndDate
					FROM HR_EmpDayOff AS T WITH (NOLOCK) INNER JOIN HR_LSKOW AS T1 WITH (NOLOCK) ON T.KowCode = T1.KowCode
					WHERE T.EmployeeID = @EmployeeCode AND T1.KowType = 9 AND @fBegDay BETWEEN T.BeginDate AND T.EndDate
				) AS R INNER JOIN HR_PayAllowance AS R1 WITH (NOLOCK) ON R.EmployeeID = R1.EmployeeID
				WHERE R1.DowCode >= @firstMonthOfYear
			) AS Z WHERE Z.Row_ID = 1
		), tblPayAllowance as (
			select *
			from (
				-- Tính cho những nhân viên không nghỉ thai sản ở tháng 12
				select T.EmployeeID, T.AlloGradeCode, T.Amount,
					ROW_NUMBER() OVER(PARTITION BY T.EmployeeID, T.AlloGradeCode ORDER BY T.FromTime desc) as Row_ID 
				FROM HR_PayAllowance AS T WITH (NOLOCK) INNER JOIN tblAlloGrade AS T1 ON T.AlloGradeCode = T1.AlloGradeCode
					LEFT JOIN tblThaiSan AS T2 ON T.EmployeeID = T2.EmployeeID
				WHERE T.DowCode = @DowCode AND T.EmployeeID = @EmployeeCode AND T2.EmployeeID IS NULL  

				-- Tính cho những nhan vien có nghi thai san o thang 12
				UNION ALL
                select T.EmployeeID, T.AlloGradeCode, T.Amount,
					ROW_NUMBER() OVER(PARTITION BY T.EmployeeID, T.AlloGradeCode ORDER BY T.FromTime desc) as Row_ID 
				FROM HR_PayAllowance AS T WITH (NOLOCK) INNER JOIN tblAlloGrade AS T1 ON T.AlloGradeCode = T1.AlloGradeCode
					INNER JOIN tblThaiSan AS T2 ON T.EmployeeID = T2.EmployeeID AND T.DowCode = T2.DowCode
			) as Z where (Z.AlloGradeCode <> 'AG_KPI') or (Z.AlloGradeCode = 'AG_KPI' and Z.Row_ID = 1)
		)
        SELECT @result = SUM(
			CASE WHEN T2.AlloGradeCode = 'AG_BSKPI' THEN T2.FixAmount ELSE
				CASE WHEN T.AlloGradeCode = 'AG_KN' THEN CASE WHEN DATEDIFF(MONTH, EffectDate, @fEndDay) 
				+ CASE WHEN DAY(EffectDate) < 15 then 1 ELSE 0 end >= 6 THEN T.Amount ELSE 0 END ELSE T.Amount END
			END
		)
		FROM tblPayAllowance as T
			INNER JOIN tblEmpAllowance AS T2 ON T.EmployeeID = T2.EmployeeID AND T.AlloGradeCode = T2.AlloGradeCode
    END
	ELSE IF @Type = 17
    BEGIN
		set @DowCode = CONVERT(varchar(7), @ToTime, 111)

		;WITH LData AS (
			SELECT RTRIM(LTRIM(data)) AS Code FROM HR_FNSplitString_varchar(@Expression, '+')
		)
        select @result = SUM(A.Amount)
        from HR_PaySalary as A with (nolock) INNER JOIN LData AS B ON A.KowCode = B.Code
        where EmployeeID = @EmployeeCode and A.DowCode = @DowCode
    END
	ELSE IF @Type = 18
    BEGIN
		select top(1) @DowCode = DowCode from HR_LSPayrollDow where BegDay <= @ToTime order by DowCode DESC
        
		DECLARE  @tmpDepartmentCode NVARCHAR(20)

		SELECT TOP(1) @DepartmentCode = DepartmentID FROM HR_Employees WITH (NOLOCK) WHERE EmployeeID = @EmployeeCode
		SELECT @tmpDepartmentCode = dbo.HR_fnGetFirstDepartmentIsFund(@DepartmentCode)
		--;WITH LData AS (
		--	SELECT RTRIM(LTRIM(data)) AS Code FROM HR_FNSplitString_varchar(@Expression, '+')
		--)
		--SELECT @result = SUM(Coefficient) 
		--FROM HCSPR_SalCoeffDept AS T WITH (NOLOCK) INNER JOIN LData AS T1 ON T.CoeffCode = T1.Code
		--WHERE DepartmentCode = @tmpDepartmentCode AND DowCode = @DowCode

    END
	ELSE IF @Type = 19
    BEGIN
		SELECT TOP(1) @DepartmentCode = DepartmentID FROM HR_Employees WITH (NOLOCK) WHERE EmployeeID = @EmployeeCode
		SELECT @tmpDepartmentCode = dbo.HR_fnGetFirstDepartmentIsFund(@DepartmentCode)

		set @DowCode = CONVERT(varchar(7), @ToTime, 111)
        select top(1) @fBegDay = FromDate, @fEndDay = ToDate from HR_ConfigTSEmpStandardWD where DowCode = @DowCode and EmployeeID = @EmployeeCode order by FromDate desc

		;with tblDeps as (
			select DepartmentCode from HR_FNGetChildDepartments(@tmpDepartmentCode)
		)
        select @result = sum(RealSalary)
        from (
            select RealSalary,
				ROW_NUMBER() OVER(PARTITION BY A.EmployeeID ORDER BY A.EffectDate desc) as Row_ID 
            from HR_EmpJWSalary as A with (nolock) inner join HR_Employees as T1 with (nolock) on A.EmployeeID = T1.EmployeeID
				inner join tblDeps as T2 on T1.DepartmentID = T2.DepartmentCode
            where (A.EffectDate <= @fEndDay and (EndDate = '' OR EndDate IS NULL OR EndDate > @fBegDay)) -- Endate này là enddate của quyết định nên khi nhân viên thôi việc vẫn lấy quyết định của nhân viên nghỉ việc ra tính.
        ) as R where Row_ID = 1
    END
	ELSE IF @Type = 20
	BEGIN
		select top(1) @DowCode = DowCode from HR_LSPayrollDow where BegDay <= @ToTime order by DowCode DESC
        
		SELECT @result = SUM(T.TotalKowSal + T.TotalAllowance)
		FROM HR_PayIncome as T WITH (NOLOCK) 
		where T.DowCode = @DowCode and T.EmployeeID = @EmployeeCode
    END
	ELSE IF @Type = 21
	BEGIN
		select top(1) @DowCode = DowCode from HR_LSPayrollDow where BegDay <= @ToTime order by DowCode DESC

		DECLARE @gPer_Union FLOAT, @gMaxPer_Union FLOAT, @gForgCurrAmtDec INT, @mTotalIncome FLOAT, @TradeAmount FLOAT, @IsTUnion bit
		SET @mTotalIncome = 0
		SET @TradeAmount = 0
		SET @IsTUnion = 0

		SELECT TOP(1) @IsTUnion = IsTUnion FROM HR_EmployeeExt WITH (NOLOCK) WHERE EmployeeID = @EmployeeCode
		-- nv khong tham gia cong doan
		IF @IsTUnion = 0
		BEGIN
			SET @result = 0
			RETURN @result
        end
		
		-- 2019.04.04 HPHoa chinh cong doan
		declare @Amount_ThuongBSL MONEY, @mTotalIncome2 MONEY						
		
		-- Tính thưởng bổ sung lương
		SELECT @Amount_ThuongBSL= isnull(SUM(T.Amount),0) 
		FROM HR_PayTExcept T with (nolock) INNER JOIN HR_LSException L with (nolock) ON T.ExceptCode = L.ExceptCode 
		WHERE EmployeeID = @EmployeeCode AND ((DowCode = @DowCode and isnull(CAST(T.Note AS NVARCHAR(MAX)), N'') = N'T2'))
		
		-- 1. luong lần 1
		SELECT @mTotalIncome = GrossSalVND - RiceAllowance - (HIAmountE + SIAmountE + UIAmountE) - 
			CASE WHEN TaxAmount > 0 THEN TaxAmount ELSE 0 END + OutTaxAmount, @TradeAmount = TUnionAmountE
		FROM HR_PayIncome WITH (NOLOCK)
		WHERE EmployeeID = @EmployeeCode AND DowCode = @DowCode AND MainPaid = 1
		--
		SET @mTotalIncome = @mTotalIncome - @Amount_ThuongBSL 


		-- 2.1 Tổng tiền lần 2 để tính công doan lần 2
		;WITH tblException AS (
			SELECT CAST(data AS INT) AS ExceptID FROM HR_FNSplitString_varchar(@Expression, '+')
		)
		SELECT @mTotalIncome2 = Sum(T.Amount - T.AmountTax)
		FROM HR_PayTExcept AS T WITH (NOLOCK) INNER JOIN tblException AS T1 ON T.ExceptCode = T1.ExceptID
		WHERE T.EmployeeID = @EmployeeCode AND T.DowCode = @DowCode

		-- 2.2 Tổng thực nhận lần 2
		SET @mTotalIncome = @mTotalIncome + @mTotalIncome2
		if @mTotalIncome < 0 
		begin
			SET @result = 0
		end
		ELSE
        begin
			-- 3. Tính cong doan lần 2
			SELECT TOP(1) @gPer_Union = PRTUnionAmount, @gMaxPer_Union = PRTUnionMaxAmount, @gForgCurrAmtDec = PRDecPlaceCurrencyForPay 
			FROM HR_ConfigPR
			
			-- so với mức trần
			SET @result = ROUND(@mTotalIncome * @gPer_Union / 100, @gForgCurrAmtDec)
			if (@gMaxPer_Union <> 0 And @gMaxPer_Union < @result) 
				SET @result = @gMaxPer_Union

			-- Sau khi so mức trần. trừ công đoàn 1
			SET @result = @result - @TradeAmount
			IF @result < 0
				SET @result = 0
		END
    END 
	ELSE IF @Type = 22
	BEGIN
		set @DowCode = CONVERT(varchar(7), @ToTime, 111)
		SELECT top(1) @fBegDay = FromDate, @fEndDay = ToDate from HR_ConfigTSEmpStandardWD WITH (NOLOCK) where DowCode = @DowCode and EmployeeID = @EmployeeCode order by FromDate DESC
       
		;with tblData as (
			select LTRIM(RTRIM(CAST([Data] AS VARCHAR(20)))) AS Code from SplitStrings_CTE(@Expression, '+')
		)
		SELECT @result = SUM(R.FixAmount)
		FROM (
			SELECT T.FixAmount, ROW_NUMBER() OVER(PARTITION BY T.EmployeeID, T.AlloGradeCode ORDER BY T.EffectDate desc) as RowID
			FROM HR_EmpAllowance AS T WITH (NOLOCK) INNER JOIN tblData AS T1 ON T.AlloGradeCode = T1.Code
			WHERE T.EmployeeID = @EmployeeCode AND T.EffectDate <= @fEndDay AND (T.EndDate IS NULL OR T.EndDate >= @fBegDay)
		) AS R WHERE R.RowID = 1
    END
	ELSE IF @Type = 23
	BEGIN
		declare @mAmount float
		set @mAmount = 0
		select @result = Sum(TaxAmount) from HR_PayIncome WITH (NOLOCK) where EmployeeID = @EmployeeCode and DowCode = @DowCode

		;with tblData as (
			select CAST([Data] AS VARCHAR(20)) AS Code from SplitStrings_CTE(@Expression, '+')
		)
		select @mAmount = SUM(T.AmountTax)
		from HR_PayTExcept as T WITH (NOLOCK) inner join tblData as T1 on T.ExceptCode = T1.Code
		where T.EmployeeID = @EmployeeCode and T.DowCode = @DowCode

		set @result = isnull(@result,0) - ISNULL(@mAmount,0)
    END
	ELSE IF @Type = 24
	BEGIN
	  -- SELECT TOP(1) @result = T1.RateMainSal
	  -- FROM HR_fnGetItemEmpTracking_FillData(@EmployeeCode, 'EmpTypeCode', @ToTime) AS T INNER JOIN (
			--SELECT EmpTypeCode, RateMainSal, CASE WHEN TrueType = 3 THEN 1 ELSE 2 END AS mOrdinal FROM HR_LSEmployeeType
	  -- ) AS T1 ON T.EmpTypeCode = T1.EmpTypeCode
	  -- ORDER BY T1.mOrdinal desc

	   IF @result IS NULL
	   BEGIN
			SELECT TOP(1) @result = T1.RateMainSal
			FROM HR_EmployeeExt AS T WITH (NOLOCK) 
				INNER JOIN HR_LSEmployeeType AS T1 WITH (NOLOCK) ON T.EmployeeTypeID = T1.EmpTypeCode
			WHERE T.EmployeeID = @EmployeeCode
	   END 

	   SET @result = @result / 100.0

    END
	ELSE IF @Type = 25
	BEGIN		
		SET @DowCode = CONVERT(varchar(7), @ToTime, 111)
		select top(1) @fBegDay = FromDate, @fEndDay = ToDate from HR_ConfigTSEmpStandardWD WITH (NOLOCK) where DowCode = @DowCode and EmployeeID = @EmployeeCode order by FromDate DESC

		--SELECT @DayLock = DateLock FROM dbo.HCSSYS_EmpLockData_Configs WITH (NOLOCK)
		--IF @DayLock IS NULL
		--	SET @DayLock = 1
		--SET @DateLock = @DowCode + '/' + RIGHT('00' + CAST(@DayLock AS VARCHAR), 2)

		--;WITH tblData as (
		--	select CAST([Data] AS VARCHAR(20)) AS Code from SplitStrings_CTE(@Expression, '+')
		--), tblHR_EmpDayOff AS (
		--	SELECT EmployeeID, RecID, RefID
		--	FROM HR_EmpDayOff AS T WITH (NOLOCK) INNER JOIN tblData AS T1 ON T.KowCode = T1.Code
		--	WHERE EmployeeID = @EmployeeCode AND BeginDate <= @fEndDay AND @fBegDay <= EndDate
		--), tblHR_EmpDayOffDetailDay AS (
		--	SELECT RecID, KowCode, DayNum
		--	FROM HR_EmpDayOffDetailDay AS T WITH (NOLOCK) INNER JOIN tblData AS T1 ON T.KowCode = T1.Code
		--	WHERE EmployeeID = @EmployeeCode AND WorkDate BETWEEN @fBegDay AND @fEndDay
		--), tblEmpDayOff AS (
		--	SELECT T.RefID, T1.KowCode, T1.DayNum
		--	FROM tblHR_EmpDayOff AS T INNER JOIN tblHR_EmpDayOffDetailDay AS T1 ON T.RecID = T1.RecID
		--)
		--SELECT @result = SUM(T.DayNum)
		--FROM tblEmpDayOff AS T INNER JOIN HCSHP_LeaveRequestDetail AS T1 ON T.RefID = T1.RecordID
		--LEFT JOIN HCSHP_LeaveRequest S ON S.RecordID = T.RefID
		--WHERE T1.CreateDate BETWEEN @DateLock AND @fEndDay AND ISNULL(S.IsHRApprove,0) = 0

		SET @result = ISNULL(@result, 0)
    END
	ELSE IF @Type = 26
	BEGIN
		SELECT @result = COUNT(*)
		FROM (
			SELECT UnionCode, ROW_NUMBER() OVER(ORDER BY BeginDate) as RowID 
			FROM HR_EmpMember WITH (NOLOCK)
			WHERE EmployeeID = @EmployeeCode AND (BeginDate IS NULL OR BeginDate <= @ToTime) AND IsActive = 1
		) AS R WHERE R.RowID = 1

		SET @result = ISNULL(@result, 0)
		IF @result > 0
			SET @result = 1
    END
	ELSE IF @Type = 27
	BEGIN
		set @DowCode = CONVERT(varchar(7), @ToTime, 111)
        SET @fBegDay = LEFT(@DowCode, 4) + '/01/01'
		SET @fEndDay = DATEADD(d, -1, DATEADD(m, DATEDIFF(m, 0, CAST(@DowCode+'/01' AS DATETIME)) + 1, 0))
		SELECT TOP(1) @JoinDate = JoinedOn, @EndDate = StoppedOn FROM HR_Employees WITH (NOLOCK) WHERE EmployeeID = @EmployeeCode
        --SELECT TOP(1) @EndDate = StoppedOn FROM HR_Employees WITH (NOLOCK) WHERE EmployeeID = @EmployeeCode

		IF @JoinDate > @fBegDay
			SET @fBegDay = @JoinDate
		--
		IF @EndDate < @fEndDay
			SET @fEndDay = @EndDate

		;WITH tblKow AS (
			SELECT CAST([Data] as varchar(20)) AS KowCode FROM SplitStrings_CTE(@Expression, '+')
		), tblConfigTSEmpStandardWD AS (
			SELECT DowCode, FromDate, ToDate, StandardWD
			FROM HR_ConfigTSEmpStandardWD WITH (NOLOCK)
			WHERE EmployeeID = @EmployeeCode AND @fBegDay <= ToDate AND FromDate <= @fEndDay
		), tblEmpDayOff_detailDay AS (
			SELECT EmployeeID, WorkDate, DayNum
			FROM HR_EmpDayOffDetailDay AS T WITH (NOLOCK) INNER JOIN tblKow AS T1
				ON T.KowCode = T1.KowCode
			WHERE EmployeeID = @EmployeeCode AND WorkDate BETWEEN @fBegDay AND @fEndDay
		)
		SELECT @result = COUNT(R.DowCode)
		FROM (
			SELECT T1.DowCode, T1.StandardWD, SUM(T.DayNum) AS DayNum
			FROM tblEmpDayOff_detailDay AS T INNER JOIN tblConfigTSEmpStandardWD AS T1
				ON T.WorkDate BETWEEN T1.FromDate AND T1.ToDate
			GROUP BY T1.DowCode, T1.StandardWD
		) AS R WHERE R.DayNum < R.StandardWD

		SET @result = ISNULL(@result, 0)
    END
	ELSE IF @Type = 28
	BEGIN		
		
		SET @DowCode = CONVERT(varchar(7), @ToTime, 111)
		select top(1) @fBegDay = FromDate, @fEndDay = ToDate from HR_ConfigTSEmpStandardWD WITH (NOLOCK) where DowCode = @DowCode and EmployeeID = @EmployeeCode order by FromDate DESC

		--SELECT @DayLock = DateLock FROM dbo.HCSSYS_EmpLockData_Configs WITH (NOLOCK)
		--IF @DayLock IS NULL
		--	SET @DayLock = 1
		--SET @DateLock = @DowCode + '/' + RIGHT('00' + CAST(@DayLock AS VARCHAR), 2)

		--;WITH tblData as (
		--	select CAST([Data] AS VARCHAR(20)) AS Code from SplitStrings_CTE(@Expression, '+')
		--), tblHR_EmpDayOff AS (
		--	SELECT EmployeeID, RecID, RefID
		--	FROM HR_EmpDayOff AS T WITH (NOLOCK) INNER JOIN tblData AS T1 ON T.KowCode = T1.Code
		--	WHERE EmployeeID = @EmployeeCode AND BeginDate <= @fEndDay AND @fBegDay <= EndDate
		--), tblHR_EmpDayOffDetailDay AS (
		--	SELECT RecID, KowCode, DayNum
		--	FROM HR_EmpDayOffDetailDay AS T WITH (NOLOCK) INNER JOIN tblData AS T1 ON T.KowCode = T1.Code
		--	WHERE EmployeeID = @EmployeeCode AND WorkDate BETWEEN @fBegDay AND @fEndDay
		--), tblEmpDayOff AS (
		--	SELECT T.RefID, T1.KowCode, T1.DayNum
		--	FROM tblHR_EmpDayOff AS T INNER JOIN tblHR_EmpDayOffDetailDay AS T1 ON T.RecID = T1.RecordID
		--)
		--SELECT @result = SUM(T.DayNum)
		--FROM tblEmpDayOff AS T INNER JOIN HCSHP_LeaveRequestDetail AS T1 ON T.RefID = T1.RecordID
		--LEFT JOIN HCSHP_LeaveRequest S ON S.RecordID = T.RefID
		--WHERE T1.CreateDate BETWEEN @fBegDay AND @DateLock OR (ISNULL(S.IsHRApprove,0) = 1 AND T1.CreateDate BETWEEN @fBegDay AND @fEndDay)

		SET @result = ISNULL(@result, 0)
    END
	ELSE IF @Type = 29
	BEGIN
		select top(1) @fBegDay = FromDate, @fEndDay = ToDate from HR_ConfigTSEmpStandardWD WITH (NOLOCK) 
		WHERE ToDate <= @ToTime and EmployeeID = @EmployeeCode order by FromDate DESC
        
		IF LTRIM(RTRIM(@Expression)) = 1
		begin
			SELECT  @result = COUNT(1) FROM (
				SELECT 1 AS iRecID
				FROM dbo.HR_TSScanTime WITH (NOLOCK)
				WHERE EmployeeID = @EmployeeCode AND WorkDate BETWEEN @fBegDay AND @fEndDay AND In1Out0 = 1
				GROUP BY WorkDate
			) AS R
		END
        ELSE IF LTRIM(RTRIM(@Expression)) = 0
		begin
			SELECT  @result = COUNT(1) FROM (
				SELECT 1 AS iRecID
				FROM dbo.HR_TSScanTime WITH (NOLOCK)
				WHERE EmployeeID = @EmployeeCode AND WorkDate BETWEEN @fBegDay AND @fEndDay AND In1Out0 = 0
				GROUP BY WorkDate
			) AS R
		END
        ELSE
		begin
			SELECT  @result = COUNT(1) FROM (
				SELECT 1 AS iRecID
				FROM dbo.HR_TSScanTime WITH (NOLOCK)
				WHERE EmployeeID = @EmployeeCode AND WorkDate BETWEEN @fBegDay AND @fEndDay
				GROUP BY WorkDate
			) AS R
		END

		SET @result = ISNULL(@result, 0)

	END
	ELSE IF @Type = 30
	BEGIN
		select top(1) @fBegDay = FromDate, @fEndDay = ToDate from HR_ConfigTSEmpStandardWD WITH (NOLOCK) 
		WHERE ToDate <= @ToTime and EmployeeID = @EmployeeCode order by FromDate DESC
        
		;WITH tblData as (
			select CAST([Data] AS VARCHAR(20)) AS Code from SplitStrings_CTE(@Expression, '+')
		)
		SELECT @result = COUNT(1)
		FROM dbo.HR_TSAssignShift AS T WITH (NOLOCK) INNER JOIN tblData AS T1 ON T.ShiftCode = T1.Code
		WHERE EmployeeID = @EmployeeCode AND T.WorkDate BETWEEN @fBegDay AND @fEndDay 
		GROUP BY T.WorkDate

		SET @result = ISNULL(@result, 0)

	END
	ELSE IF @Type = 31
	BEGIN
		--SELECT TOP(1) @result = Coeff FROM dbo.HR_Positions WITH (NOLOCK) WHERE Coeff = LTRIM(RTRIM(@Expression)) --Chưa chuyển cấu trúc bảng sang Codx nên chưa có field Coeff

		SET @result = ISNULL(@result, 0)
    END 
	ELSE IF @Type = 32
	BEGIN
		SET @DowCode = CONVERT(VARCHAR(7), @ToTime, 111)
		SELECT @result = COUNT(1)
		FROM dbo.HR_EmpFamily 
		WHERE EmployeeID = @EmployeeCode AND IsReduceTax = 1 
			AND @DowCode >= FromMonth
			AND @DowCode <= ISNULL(ToMonth, @DowCode)
		
		SET @result = ISNULL(@result, 0)
    END 
	ELSE IF @Type = 33
	BEGIN
		set @fBegDay = @ToTime
		set @fEndDay = @ToTime

		;with tblAlloGrade as (
			select B.AlloGradeCode, B.IsFixAmount from HR_FNSplitString_varchar(@Expression, '+') as A inner join HR_LSAlloGrade as B on ltrim(rtrim(A.[data])) = B.AlloGradeCode
		)
		select @result = sum(Amount)
		from (
			select AG.AlloGradeCode as ID, case when AG.IsFixAmount = 1 then A.FixAmount else A.SalaryRate end as Amount,
				ROW_NUMBER() OVER(PARTITION BY AG.AlloGradeCode ORDER BY EffectDate desc) as Row_ID
			from HR_EmpAllowance as A with (nolock) inner join tblAlloGrade as AG WITH (NOLOCK) on A.AlloGradeCode = AG.AlloGradeCode
			where EmployeeID = @EmployeeCode and 
				(EffectDate <= @fEndDay and (EndDate = '' OR EndDate IS NULL OR EndDate > @fBegDay))
		) as R where Row_ID = 1
	END
	ELSE IF @Type = 34
    BEGIN
		set @fBegDay = @ToTime
		set @fEndDay = @ToTime

        select @result = sum(RealSalary)
        from (
            select RealSalary,
                ROW_NUMBER() OVER(ORDER BY EffectDate desc) as Row_ID
            from HR_EmpBasicSalary as A with (nolock)
            where EmployeeID = @EmployeeCode and 
                (EffectDate <= @fEndDay and (EndDate = '' OR EndDate IS NULL OR EndDate > @fBegDay))
        ) as R where Row_ID = 1

		SET @result = ISNULL(@result, 0)
    END
	ELSE IF @Type = 35
    BEGIN
		;with tblAlloGrade as (
			SELECT RTRIM(LTRIM(data)) AS AlloGradeCode FROM HR_FNSplitString_varchar(@Expression, '+')
		)
		SELECT @result = SUM(T.Amount)
		FROM dbo.HR_PayAllowance AS T WITH (NOLOCK) INNER JOIN tblAlloGrade AS T1 ON T.AlloGradeCode = T1.AlloGradeCode
		WHERE T.EmployeeID = @EmployeeCode AND T.DowCode = @DowCode

		SET @result = ISNULL(@result, 0)
    END
	ELSE IF @Type = 36
    BEGIN
		-- Nếu tháng đang xét là tháng cuối cùng của Quý thì xử lý
		IF MONTH(@ToTime) IN (3,6,9,12)
		BEGIN
			DECLARE @Month_sub1 DATETIME, @Month_sub2 DATETIME

			SELECT TOP(1) @fEndDay = ToDate
			FROM dbo.HR_ConfigTSEmpStandardWD WITH (NOLOCK) WHERE EmployeeID = @EmployeeCode AND	FromDate <= @ToTime
			ORDER BY FromDate DESC
            
			SET @Month_sub1 = DATEADD(MONTH, -1, @fEndDay)
			SET @Month_sub2 = DATEADD(MONTH, -2, @fEndDay)

			;WITH tblSal AS (
				SELECT RealSalary, EffectDate
				FROM dbo.HR_EmpBasicSalary WITH (NOLOCK)
				WHERE EmployeeID = @EmployeeCode
			)
			SELECT @result = ISNULL(SUM(R.RealSalary), 0)
			FROM (
				SELECT TOP(1) RealSalary FROM tblSal WHERE EffectDate <= @fEndDay ORDER BY tblSal.EffectDate desc
				UNION ALL
                SELECT TOP(1) RealSalary FROM tblSal WHERE EffectDate <= @Month_sub1 ORDER BY tblSal.EffectDate desc
				UNION ALL
                SELECT TOP(1) RealSalary FROM tblSal WHERE EffectDate <= @Month_sub2 ORDER BY tblSal.EffectDate desc
			) AS R

        END
        
		SET @result = ISNULL(@result, 0)
    END
	ELSE IF @Type = 37
    BEGIN		
		SELECT TOP(1) @fBegDay = FromDate, @fEndDay = ToDate
		FROM dbo.HR_ConfigTSEmpStandardWD WITH (NOLOCK) WHERE EmployeeID = @EmployeeCode AND	FromDate <= @ToTime
		ORDER BY FromDate DESC

		;WITH LData AS (
			SELECT RTRIM(LTRIM(data)) AS KowCode FROM HR_FNSplitString_varchar(@Expression, '+')
		)
		select @tsBegDate = min(T.BeginDate), @tsEndDate = max(T.EndDate)
		from HR_EmpDayOff as T with (nolock) inner join LData as T1 on T.KowCode = T1.KowCode
		where EmployeeID = @EmployeeCode and BeginDate <= @fEndDay and @fBegDay <= EndDate

		if @tsBegDate is not null
		begin
			if @fBegDay < @tsBegDate
				set @tmpBegDate = @tsBegDate
			else
				set @tmpBegDate = @fBegDay

			if @fEndDay > @tsEndDate
				set @tmpEndDate = @tsEndDate
			else
				set @tmpEndDate = @fEndDay


			if @tsBegDate between @fBegDay and @fEndDay
			begin
				select @result = dbo.HR_fnFGetht_DemCongMacDinh(@EmployeeCode, @DowCode, @fBegDay, @tmpBegDate - 1, 1)
			end
			
			if @tsEndDate between @fBegDay and @fEndDay
			begin
				select @result = dbo.HR_fnFGetht_DemCongMacDinh(@EmployeeCode, @DowCode, @tmpEndDate + 1, @fEndDay, 1)
			end
		end

		SET @result = ISNULL(@result, 0)
    END
	ELSE IF @Type = 38
    BEGIN
		SELECT TOP(1) @fBegDay = FromDate, @fEndDay = ToDate
		FROM dbo.HR_ConfigTSEmpStandardWD WITH (NOLOCK) WHERE EmployeeID = @EmployeeCode AND	FromDate <= @ToTime
		ORDER BY FromDate DESC

		-- kiem tra cong thai san		
		;WITH LData AS (
			SELECT RTRIM(LTRIM(data)) AS KowCode FROM HR_FNSplitString_varchar(@Expression, '+')
		)
		select @result = count(1)
		from HR_EmpDayOff as T with (nolock) inner join LData as T1 on T.KowCode = T1.KowCode
		where EmployeeID = @EmployeeCode and BeginDate <= @fEndDay and @fBegDay <= EndDate

		SET @result = ISNULL(@result, 0)
    END
	ELSE IF @Type = 39
    BEGIN		
		SELECT TOP(1) @fBegDay = FromDate, @fEndDay = ToDate
		FROM dbo.HR_ConfigTSEmpStandardWD WITH (NOLOCK) WHERE EmployeeID = @EmployeeCode AND	FromDate <= @ToTime
		ORDER BY FromDate DESC

		;WITH LData AS (
			SELECT RTRIM(LTRIM(data)) AS KowCode FROM HR_FNSplitString_varchar(@Expression, '+')
		)
		select @tsBegDate = min(T.BeginDate), @tsEndDate = max(T.EndDate)
		from HR_EmpDayOff as T with (nolock) inner join LData as T1 on T.KowCode = T1.KowCode
		where EmployeeID = @EmployeeCode and BeginDate <= @fEndDay and @fBegDay <= EndDate

		if @tsBegDate is not null
		begin
			if @fBegDay < @tsBegDate
				set @tmpBegDate = @tsBegDate
			else
				set @tmpBegDate = @fBegDay

			if @fEndDay > @tsEndDate
				set @tmpEndDate = @tsEndDate
			else
				set @tmpEndDate = @fEndDay

			if @tsBegDate is not null
				select @result = dbo.HR_fnFGetht_DemCongMacDinh(@EmployeeCode, @DowCode, @tmpBegDate, @tmpEndDate, 1)
		end

		SET @result = ISNULL(@result, 0)
    END
	ELSE IF @Type = 40
    BEGIN
		set @fBegDay = cast(year(@ToTime) as varchar) + '/01/01'
		set @fEndDay = cast(year(@ToTime) as varchar) + '/12/31'

		;WITH LData AS (
			SELECT RTRIM(LTRIM(data)) AS KowCode FROM HR_FNSplitString_varchar(@Expression, '+')
		)
		select @tsBegDate = min(T.BeginDate), @tsEndDate = max(T.EndDate)
		from HR_EmpDayOff as T with (nolock) inner join LData as T1 on T.KowCode = T1.KowCode
		where EmployeeID = @EmployeeCode and BeginDate <= @fEndDay and @fBegDay <= EndDate

		if @tsBegDate is not null
		begin
			if @tsBegDate < @fBegDay
				set @tsBegDate = @fBegDay

			if @tsEndDate > @fEndDay
				set @tsEndDate = @fEndDay

			set @result = datediff(day, @tsBegDate, @tsEndDate) + 1
		end
		SET @result = ISNULL(@result, 0)
    END
	ELSE IF @Type = 41
	BEGIN
		DECLARE @HR_LSPayrollDow TABLE(DowCode VARCHAR(7))
		
		INSERT INTO @HR_LSPayrollDow(DowCode)
		SELECT DowCode
		FROM HR_LSPayrollDow WITH (NOLOCK)
		WHERE LEFT(DowCode, 4) = YEAR(@ToTime) AND DowCode <= CONVERT(VARCHAR(7), @ToTime, 111)

		SELECT @tmpValue = COUNT(DowCode) FROM @HR_LSPayrollDow

		SELECT @result = SUM(T.GrossSalVND)
		FROM HR_PayIncome as T WITH (NOLOCK) INNER JOIN @HR_LSPayrollDow AS T1 ON T.DowCode = T1.DowCode
		where T.EmployeeID = @EmployeeCode

		IF @tmpValue > 0
			SET @result = ISNULL(@result, 0) / @tmpValue
		ELSE
			SET @result = 0
	END
	ELSE IF @Type = 42
	BEGIN
		-- Lấy giá trị mặc định của hệ số lương thưởng
		;WITH LData AS (
			SELECT RTRIM(LTRIM(data)) AS Code FROM HR_FNSplitString_varchar(@Expression, '+')
		)
		SELECT @result = SUM(T.Coefficient)
		FROM HR_PRSalCoeffEmp as T WITH (NOLOCK) INNER JOIN LData AS T1 ON T.CoeffCode = T1.Code
		where T.EmployeeID = @EmployeeCode and T.ToTime = @ToTime
    END
	ELSE IF @Type = 43
	BEGIN
	   SELECT @result = count(1)
	   FROM HR_fnGetItemEmpTracking_FillData(@EmployeeCode, 'GroupSalCode', @ToTime) AS T

	   set @result = isnull(@result, 0)

    END
	ELSE IF @Type = 44
    BEGIN
		set @DowCode = CONVERT(varchar(7), @ToTime, 111)
		;WITH LData AS (
			SELECT RTRIM(LTRIM(data)) AS Code FROM HR_FNSplitString_varchar(@Expression, '+')
		)
        select @result = SUM(A.Amount)
        from HR_PaySalary as A with (nolock) INNER JOIN LData AS B ON A.KowCode = B.Code
        where EmployeeID = @EmployeeCode and A.DowCode = @DowCode AND A.FromTime <= @ToTime
    END
	ELSE IF @Type = 45
    BEGIN
		set @DowCode = CONVERT(varchar(7), @ToTime, 111)

		;WITH LData AS (
			SELECT RTRIM(LTRIM(data)) AS Code FROM HR_FNSplitString_varchar(@Expression, '+')
		)
        select @result = SUM(A.Amount)
        from HR_PaySalaryLastPayroll as A with (nolock) INNER JOIN LData AS B ON A.KowCode = B.Code
        where EmployeeID = @EmployeeCode and A.DowCode = @DowCode
    END
	ELSE IF @Type = 46
	BEGIN
		SELECT TOP(1) @DowCode = DowCode FROM dbo.HR_ConfigTSEmpStandardWD WHERE EmployeeID = @EmployeeCode AND FromDate <= @ToTime ORDER BY FromDate desc
		SELECT @result = sum(SIAmountE + SIAmountC) FROM HR_SocialIns WITH (NOLOCK) WHERE DowCode = @DowCode AND EmployeeID = @EmployeeCode

	END
	ELSE IF @Type = 47
	BEGIN
		DECLARE @FromCurrencyCode VARCHAR(3), @PRCurrencyForPay VARCHAR(3), @ToCurrencyCode VARCHAR(3), @DecPlace FLOAT
		DECLARE @PRDecPlaceCurrencyForPay FLOAT, @FromCurrencyCode_ExtRate FLOAT, @ToCurrencyCode_ExtRate FLOAT

		IF NOT EXISTS(SELECT TOP(1) 1 FROM dbo.HR_EmpTracking WITH (NOLOCK)
			WHERE EmployeeID = @EmployeeCode AND TableName = 'HR_EmployeeExt' AND FieldName = 'CurrencyCode')
		BEGIN
			SELECT TOP(1) @FromCurrencyCode = CurrencyCode FROM dbo.HR_EmployeeExt WITH (NOLOCK) WHERE EmployeeID = @EmployeeCode	
        END 
		ELSE
        BEGIN
			;WITH tblTmp AS (
				SELECT EffectDate, Value, ValueOld FROM HR_EmpTracking WITH (NOLOCK)
				WHERE EmployeeID = @EmployeeCode AND TableName = 'HR_EmployeeExt' AND FieldName = 'CurrencyCode'
			)
			SELECT @FromCurrencyCode = CASE WHEN EffectDate <= @ToTime THEN Value else ValueOld end
			FROM (
				SELECT EffectDate, Value, ValueOld, ROW_NUMBER() OVER(ORDER BY EffectDate) as RowID
				FROM (
					SELECT TOP(1) A.EffectDate, A.Value, A.ValueOld FROM tblTmp AS A ORDER BY EffectDate ASC
					UNION ALL
					SELECT A.EffectDate, A.Value, A.ValueOld FROM tblTmp AS A WHERE A.EffectDate <= @ToTime
				) AS R
			) AS Z WHERE Z.RowID = 1
        END 
    END
	ELSE IF @Type = 48
	BEGIN
		set @DowCode = CONVERT(varchar(7), @ToTime, 111)
        select top(1) @fBegDay = FromDate, @fEndDay = ToDate from HR_ConfigTSEmpStandardWD WITH (NOLOCK) where DowCode = @DowCode and EmployeeID = @EmployeeCode order by FromDate DESC
        
		;WITH tblKow AS (
			SELECT LTRIM(RTRIM(data)) AS KowCode FROM dbo.SplitStrings_CTE(@Expression, '+')
		)
		SELECT @result = CASE WHEN COUNT(1) = (SELECT COUNT(1) FROM tblKow) THEN 1 ELSE 0 end
		FROM (
			SELECT T.KowCode
			FROM dbo.HR_TSKowDs AS T WITH (NOLOCK) --INNER JOIN tblKow AS T1 ON T.KowCode = T1.KowCode
			WHERE T.EmployeeID = @EmployeeCode AND T.WorkDate BETWEEN @fBegDay AND @fEndDay
			GROUP BY T.KowCode
		) AS R
    END
	ELSE IF @Type = 49
    BEGIN
		SELECT top(1) @fBegDay = FromDate, @fEndDay = ToDate from HR_ConfigTSEmpStandardWD where ToDate <= @ToTime and EmployeeID = @EmployeeCode order by FromDate desc
		select @result = sum(InsSalary)
		from (
			select InsSalary, ROW_NUMBER() OVER(ORDER BY EffectDate desc) as Row_ID
			from HR_EmpBasicSalary as A with (nolock)
			where EmployeeID = @EmployeeCode and 
				(EffectDate <= @fEndDay and (EndDate = '' OR EndDate IS NULL OR EndDate > @fBegDay))
		) as R where Row_ID = 1
    END
	ELSE IF @Type = 50
	BEGIN
		;with tblAlloGrade as (
			select B.AlloGradeCode, B.IsFixAmount from HR_FNSplitString_varchar(@Expression, '+') as A inner join HR_LSAlloGrade as B on ltrim(rtrim(A.[data])) = B.AlloGradeCode
		)
		select @result = sum(Amount)
		from (
			select AG.AlloGradeCode as ID, case when AG.IsFixAmount = 1 then A.FixAmount else A.SalaryRate end as Amount,
				ROW_NUMBER() OVER(PARTITION BY AG.AlloGradeCode ORDER BY EffectDate desc) as Row_ID
			from HR_EmpAllowance as A with (nolock) inner join tblAlloGrade as AG WITH (NOLOCK) on A.AlloGradeCode = AG.AlloGradeCode
			where EmployeeID = @EmployeeCode and 
				(EffectDate <= @ToTime and (EndDate = '' OR EndDate IS NULL OR EndDate >= @ToTime))
		) as R where Row_ID = 1
	END
	ELSE IF @Type = 51
	BEGIN
		SET @tmpValue = YEAR(@ToTime)
		-- Lay gia tri thu nhap khac trong TExcepts
		;WITH LData AS (
			SELECT RTRIM(LTRIM(data)) AS Code FROM HR_FNSplitString_varchar(@Expression, '+')
		)
		SELECT @result = SUM(T.Amount)
		FROM HR_PayTExcept as T WITH (NOLOCK) INNER JOIN LData AS T1 ON T.ExceptCode = T1.Code
		WHERE T.EmployeeID = @EmployeeCode AND LEFT(DowCode, 4) = @tmpValue
	END
	ELSE IF @Type = 52
	BEGIN
		SET @result = (DATEDIFF(m, CAST(CAST(YEAR(@ToTime) AS VARCHAR) + '/' + CAST(month(@ToTime) AS VARCHAR) + '/01' AS DATE),
			CAST(CAST(YEAR(@ToTime) AS VARCHAR) + '/12/31' AS DATE)) + 1)
	END
	ELSE IF @Type = 53
	BEGIN
		SELECT top(1) @DowCode = DowCode FROM HR_ConfigTSEmpStandardWD WITH (NOLOCK)
		WHERE FromDate <= @ToTime and EmployeeID = @EmployeeCode order by FromDate desc

		-- Lay gia tri thu nhap khac trong TExcepts
		;WITH LData AS (
			SELECT RTRIM(LTRIM(data)) AS Code FROM HR_FNSplitString_varchar(@Expression, '+')
		)
		SELECT @result = SUM(T.AmountF)
		FROM HR_PayTExcept as T WITH (NOLOCK) INNER JOIN LData AS T1 ON T.ExceptCode = T1.Code
		WHERE T.EmployeeID = @EmployeeCode AND DowCode = @DowCode
	END
	ELSE IF @Type = 54
	BEGIN
		SET @result = DATEPART(dy,DATEFROMPARTS(YEAR(@ToTime),12,31))
	END
	ELSE IF @Type = 55
	BEGIN
		DECLARE @PRSIAdjDowCodeType INT, @PRSITotalPaidDays INT, @gSGMC FLOAT, @PRSIPaidDayKowCodes VARCHAR(MAX)
        DECLARE @tmpDayNum FLOAT, @IsDeduction BIT, @FDate DATETIME, @TDate DATETIME, @OfficialDate DATETIME

		SET @IsDeduction = 0
		--
		SELECT TOP(1) @PRSIAdjDowCodeType = PRSIAdjDowCodeType, @PRSITotalPaidDays = PRSITotalPaidDays, @PRSIPaidDayKowCodes = PRSIPaidDayKowCodes 
		FROM HR_ConfigPR WITH (NOLOCK)
		--
		SELECT TOP(1) @gSGMC = CASE WHEN TSHoursPerWD = 1 THEN 8 ELSE 1 end from HR_ConfigTSEmp with (nolock) where EmployeeID = @EmployeeCode
		-- 
		SELECT TOP(1) @OfficialDate = HiredOn FROM dbo.HR_Employees WITH (NOLOCK) WHERE EmployeeID = @EmployeeCode

		IF EXISTS(SELECT TOP(1) 1 FROM HR_ConfigPRSubAutoBackCollectSI WITH (NOLOCK) WHERE AddAdjType in (7,8))
		BEGIN
			-- Tháng trích nộp
			IF @PRSIAdjDowCodeType = 0
			BEGIN
				--ngay bat dau va ngay ket thuc cua 'gia tri ngay nghi viec lam can cu bao giam'
				SET @FDate = Convert(datetime, @DowCode + '/01', 102)
				SET @TDate =  DateAdd(day, -1, DateAdd(month, DateDiff(month, 0, @FDate)+1, 0))

				SET @fBegDay = @FDate
				SET @fEndDay = @TDate
			END
			ELSE
			BEGIN
				SELECT TOP(1) @fBegDay = FromDate, @fEndDay = ToDate FROM dbo.HR_ConfigTSEmpStandardWD WITH (NOLOCK) WHERE EmployeeID = @EmployeeCode AND DowCode = @DowCode
			END
            
			IF @OfficialDate IS NOT NULL AND @fBegDay < @OfficialDate
				SET @fBegDay = @OfficialDate

			-- Tổng số ngày công hưởng lương
			IF EXISTS(SELECT TOP(1) 1 FROM HR_ConfigPRSubAutoBackCollectSI WITH (NOLOCK) WHERE AddAdjType = 7)
				SELECT TOP(1) @PRSITotalPaidDays = 50 * StandardWD / 100 FROM dbo.HR_ConfigTSEmpStandardWD WITH (NOLOCK) WHERE EmployeeID = @EmployeeCode AND DowCode = @DowCode
			ELSE 
				SELECT TOP(1) @PRSITotalPaidDays = (StandardWD - 14) * @gSGMC FROM dbo.HR_ConfigTSEmpStandardWD WITH (NOLOCK) WHERE EmployeeID = @EmployeeCode AND DowCode = @DowCode

			;WITH tblA AS (
				SELECT LTRIM(RTRIM(CAST(data AS VARCHAR(20)))) AS KowCode FROM dbo.HR_FNSplitString_varchar(@PRSIPaidDayKowCodes, ',')
			)
			SELECT @tmpDayNum = ISNULL(SUM(T.DayNum), 0)
			FROM dbo.HR_TSKowDs AS T WITH (NOLOCK) INNER JOIN tblA AS T1 ON T.KowCode = T1.KowCode
			WHERE T.EmployeeID = @EmployeeCode AND T.WorkDate BETWEEN @fBegDay AND @fEndDay

			IF @tmpDayNum > @PRSITotalPaidDays AND @PRSITotalPaidDays > 0
			begin
				IF EXISTS(SELECT TOP(1) 1 FROM HR_SocialIns WITH (NOLOCK) 
					WHERE DowCode = @DowCode AND EmployeeID = @EmployeeCode AND SIAmountE > 0)
				OR EXISTS(SELECT TOP(1) 1 FROM dbo.HR_SocialInsAdjust WITH (NOLOCK) 
					WHERE AdjDowCode = @DowCode AND EmployeeID = @EmployeeCode AND SIAmountE > 0)
					SET @IsDeduction = 1
				ELSE
					SET @IsDeduction = 0
			end
			else
			BEGIN
				SET @IsDeduction = 0
			end
		END

		SET @result = @IsDeduction
	END
	ELSE IF @Type = 56
	BEGIN
		IF EXISTS(SELECT TOP(1) 1 FROM HR_SocialIns WITH (NOLOCK) 
			WHERE DowCode = @DowCode AND EmployeeID = @EmployeeCode AND SIAmountE > 0 and HIAmountE > 0 and UIAmountE > 0)
		OR EXISTS(SELECT TOP(1) 1 FROM dbo.HR_SocialInsAdjust WITH (NOLOCK) 
			WHERE AdjDowCode = @DowCode AND EmployeeID = @EmployeeCode AND SIAmountE > 0 and HIAmountE > 0 and UIAmountE > 0
				AND NumAdd NOT IN (27, 28))
			SET @result = 1
		ELSE
			SET @result = 0
			
	END
	ELSE IF @Type = 57
	BEGIN
		SET @fBegDay = CAST(YEAR(@ToTime) AS VARCHAR) + '/01/01'
		SET @fEndDay = CAST(YEAR(@ToTime) AS VARCHAR) + '/12/31'

		SELECT TOP(1) @JoinDate = JoinedOn FROM HR_Employees WITH (NOLOCK) WHERE EmployeeID = @EmployeeCode
		IF @JoinDate BETWEEN @fBegDay AND @fEndDay
		begin
			SET @result = (DATEDIFF(DAY, @JoinDate, @fEndDay) + 1) * 1.0 / (DATEDIFF(DAY, @fBegDay, @fEndDay) + 1) * 1.0
			
		END
		ELSE
        BEGIN
			SET @result = 1
		END 
	END
	ELSE IF @Type = 58
	BEGIN
		IF @Expression = 'KQDanhGia_Thang'
		BEGIN
			SET @iMonth = MONTH(@ToTime)

			SELECT TOP(1) @AprRankCode = AprRankCode
			FROM dbo.HR_AprPeriodic WITH (NOLOCK)
			WHERE EmployeeID = @EmployeeCode AND AprYear = @iYear and AprPeriod = @iMonth

			SELECT TOP(1) @result = TotalFrom FROM dbo.HR_LSRank WITH (NOLOCK) WHERE RankCode = @AprRankCode
        END
		ELSE IF @Expression = 'KQDanhGia_Nam'
		BEGIN
			SELECT TOP(1) @AprRankCode = AprRankCode
			FROM dbo.HR_AprPeriodic WITH (NOLOCK)
			WHERE EmployeeID = @EmployeeCode AND AprYear = @iYear and AprPeriod = 19

			SELECT TOP(1) @result = TotalFrom FROM dbo.HR_LSRank WITH (NOLOCK) WHERE RankCode = @AprRankCode
        END
		ELSE IF @Expression = 'KQDanhGia_Quy'
		BEGIN
			SET @iMonth = CASE MONTH(@ToTime) 
				WHEN 1 THEN 13
				WHEN 2 THEN 13
				WHEN 3 THEN 13
				WHEN 4 THEN 14
				WHEN 5 THEN 14
				WHEN 6 THEN 14
				WHEN 7 THEN 15
				WHEN 8 THEN 15
				WHEN 9 THEN 15
				WHEN 10 THEN 16
				WHEN 11 THEN 16
				WHEN 12 THEN 16 END 

			SELECT TOP(1) @AprRankCode = AprRankCode
			FROM dbo.HR_AprPeriodic WITH (NOLOCK)
			WHERE EmployeeID = @EmployeeCode AND AprYear = @iYear and AprPeriod = @iMonth

			SELECT TOP(1) @result = TotalFrom FROM dbo.HR_LSRank WITH (NOLOCK) WHERE RankCode = @AprRankCode
        END
		ELSE IF @Expression = 'KQDanhGia_NuaNam'
		BEGIN
			SET @iMonth = CASE MONTH(@ToTime) 
				WHEN 1 THEN 17
				WHEN 2 THEN 17
				WHEN 3 THEN 17
				WHEN 4 THEN 17
				WHEN 5 THEN 17
				WHEN 6 THEN 17
				WHEN 7 THEN 18
				WHEN 8 THEN 18
				WHEN 9 THEN 18
				WHEN 10 THEN 18
				WHEN 11 THEN 18
				WHEN 12 THEN 18 END 

			SELECT TOP(1) @AprRankCode = AprRankCode
			FROM dbo.HR_AprPeriodic WITH (NOLOCK)
			WHERE EmployeeID = @EmployeeCode AND AprYear = @iYear and AprPeriod = @iMonth

			SELECT TOP(1) @result = TotalFrom FROM dbo.HR_LSRank WITH (NOLOCK) WHERE RankCode = @AprRankCode
        END
    END
	ELSE IF @Type = 59
	BEGIN
		IF @Expression = 'KQDanhGia_Thang'
		BEGIN
			SET @iMonth = MONTH(@ToTime)

			SELECT TOP(1) @AprRankCode = AprRankCode
			FROM dbo.HR_AprPeriodic WITH (NOLOCK)
			WHERE EmployeeID = @EmployeeCode AND AprYear = @iYear and AprPeriod = @iMonth

			SELECT TOP(1) @result = Coefficient FROM dbo.HR_LSRank WITH (NOLOCK) WHERE RankCode = @AprRankCode
        END
		ELSE IF @Expression = 'KQDanhGia_Nam'
		BEGIN
			SELECT TOP(1) @AprRankCode = AprRankCode
			FROM dbo.HR_AprPeriodic WITH (NOLOCK)
			WHERE EmployeeID = @EmployeeCode AND AprYear = @iYear and AprPeriod = 19

			SELECT TOP(1) @result = Coefficient FROM dbo.HR_LSRank WITH (NOLOCK) WHERE RankCode = @AprRankCode
        END
		ELSE IF @Expression = 'KQDanhGia_Quy'
		BEGIN
			SET @iMonth = CASE MONTH(@ToTime) 
				WHEN 1 THEN 13
				WHEN 2 THEN 13
				WHEN 3 THEN 13
				WHEN 4 THEN 14
				WHEN 5 THEN 14
				WHEN 6 THEN 14
				WHEN 7 THEN 15
				WHEN 8 THEN 15
				WHEN 9 THEN 15
				WHEN 10 THEN 16
				WHEN 11 THEN 16
				WHEN 12 THEN 16 END 

			SELECT TOP(1) @AprRankCode = AprRankCode
			FROM dbo.HR_AprPeriodic WITH (NOLOCK)
			WHERE EmployeeID = @EmployeeCode AND AprYear = @iYear and AprPeriod = @iMonth

			SELECT TOP(1) @result = Coefficient FROM dbo.HR_LSRank WITH (NOLOCK) WHERE RankCode = @AprRankCode
        END
		ELSE IF @Expression = 'KQDanhGia_NuaNam'
		BEGIN
			SET @iMonth = CASE MONTH(@ToTime) 
				WHEN 1 THEN 17
				WHEN 2 THEN 17
				WHEN 3 THEN 17
				WHEN 4 THEN 17
				WHEN 5 THEN 17
				WHEN 6 THEN 17
				WHEN 7 THEN 18
				WHEN 8 THEN 18
				WHEN 9 THEN 18
				WHEN 10 THEN 18
				WHEN 11 THEN 18
				WHEN 12 THEN 18 END 

			SELECT TOP(1) @AprRankCode = AprRankCode
			FROM dbo.HR_AprPeriodic WITH (NOLOCK)
			WHERE EmployeeID = @EmployeeCode AND AprYear = @iYear and AprPeriod = @iMonth

			SELECT TOP(1) @result = Coefficient FROM dbo.HR_LSRank WITH (NOLOCK) WHERE RankCode = @AprRankCode
        END
    END
	ELSE IF @Type = 60
	BEGIN
		SELECT TOP(1) @result = ISNULL(IsUnPaySal,0) FROM dbo.HR_EmployeeExt WITH (NOLOCK) WHERE EmployeeID = @EmployeeCode
	END 
	ELSE IF @Type = 61
	BEGIN
		SELECT TOP(1) @result = ISNULL(UnPaySalAmount,0) FROM dbo.HR_EmployeeExt WITH (NOLOCK) WHERE EmployeeID = @EmployeeCode
	END
	ELSE IF @Type = 62
	BEGIN
		select top(1) @fBegDay = FromDate, @fEndDay = ToDate, @DowCode = DowCode 
		from HR_ConfigTSEmpStandardWD WITH (NOLOCK) WHERE ToDate <= @ToTime and EmployeeID = @EmployeeCode order by FromDate DESC

		-- Lấy hợp đồng mới nhất còn hiệu lực.
		select @tmpString = R.ConTypeCode
		from (
			select A.ConTypeCode, ROW_NUMBER() OVER(ORDER BY A.ContFrom desc) as Row_ID, A.ContTo
			from dbo.HR_EmpContract as A with (nolock)
			where EmployeeID = @EmployeeCode and A.ContFrom <= @fEndDay
		) as R where Row_ID = 1 AND (R.ContTo IS NULL OR R.ContTo >= @fBegDay)

		SELECT TOP(1) @GroupCode = B.GroupRider
		FROM dbo.HR_EmployeeExt AS A WITH (NOLOCK) INNER JOIN dbo.HR_LSRegion AS B WITH (NOLOCK) ON A.AssignRegionCode = B.RegionCode
		WHERE EmployeeID = @EmployeeCode

		-- he so
		;WITH tblA AS (
			SELECT CAST(LTRIM(RTRIM(data)) AS VARCHAR(20)) AS Code FROM dbo.HR_FNSplitString_varchar(@Expression, '+')
		)
		SELECT @tmpDayNum = ISNULL(SUM(T.Coefficient), 0)
		FROM dbo.HR_PRSalCoeffEmp AS T WITH (NOLOCK) INNER JOIN tblA AS T1 ON T.CoeffCode = T1.Code
		WHERE T.EmployeeID = @EmployeeCode AND T.DowCode = @DowCode

		--SELECT @result = SUM(Amount)
		--FROM HCSLS_SalarybyContractType_NJV WITH (NOLOCK) 
		--WHERE ConTypeCode = @tmpString AND @tmpDayNum >= FromNum AND @tmpDayNum <= ToNum and GroupCode = @GroupCode
	END
	ELSE IF @Type = 63
	BEGIN

		SELECT top(1) @fBegDay = FromDate, @fEndDay = ToDate, @DowCode = DowCode from HR_ConfigTSEmpStandardWD WITH (NOLOCK) WHERE ToDate <= @ToTime and EmployeeID = @EmployeeCode order by FromDate DESC

		SELECT TOP(1) @tmpString = B.GroupRider
		FROM dbo.HR_EmployeeExt AS A WITH (NOLOCK) INNER JOIN dbo.HR_LSRegion AS B WITH (NOLOCK) ON A.AssignRegionCode = B.RegionCode
		WHERE EmployeeID = @EmployeeCode

		;WITH tblA AS (
			SELECT LTRIM(RTRIM(data)) AS Code FROM dbo.HR_FNSplitString_varchar(@Expression, '+')
		)
		SELECT @tmpDayNum = ISNULL(SUM(T.Coefficient), 0)
		FROM dbo.HR_PRSalCoeffEmp AS T WITH (NOLOCK) INNER JOIN tblA AS T1 ON T.CoeffCode = T1.Code
		WHERE T.EmployeeID = @EmployeeCode AND T.DowCode = @DowCode

		--SELECT @result = SUM((T.ToNum - T.FromNum) * T.Amount)
		--FROM (
		--	SELECT T.Amount, T.FromNum, CASE WHEN @tmpDayNum < T.ToNum THEN @tmpDayNum ELSE T.ToNum END AS ToNum, 
		--		DENSE_RANK() OVER (PARTITION BY T.GroupCode ORDER BY GroupCode, T.EffectDate desc) AS Row_ID
		--	FROM HCSLS_BonusPerformancebyQuantity_NJV AS T WITH (NOLOCK)
		--	WHERE T.GroupCode = @tmpString AND T.EffectDate <= @fEndDay
		--) AS T WHERE T.Row_ID = 1 AND T.FromNum <= @tmpDayNum
	END
	ELSE IF @Type = 64
	BEGIN
		select top(1) @fBegDay = FromDate, @fEndDay = ToDate, @DowCode = DowCode from HR_ConfigTSEmpStandardWD WITH (NOLOCK) WHERE ToDate <= @ToTime and EmployeeID = @EmployeeCode order by FromDate DESC

		SELECT TOP(1) @GroupCode = B.GroupRider
		FROM dbo.HR_EmployeeExt AS A WITH (NOLOCK) INNER JOIN dbo.HR_LSRegion AS B WITH (NOLOCK) ON A.AssignRegionCode = B.RegionCode
		WHERE EmployeeID = @EmployeeCode

		-- Lấy hợp đồng mới nhất còn hiệu lực.
		select @tmpString = R.ConTypeCode
		from (
			select A.ConTypeCode, ROW_NUMBER() OVER(ORDER BY A.ContFrom desc) as Row_ID, A.ContTo
			from dbo.HR_EmpContract as A with (nolock)
			where EmployeeID = @EmployeeCode and A.ContFrom <= @fEndDay
		) as R where Row_ID = 1 AND (R.ContTo IS NULL OR R.ContTo >= @fBegDay)

		-- he so
		;WITH tblA AS (
			SELECT CAST(LTRIM(RTRIM(data)) AS VARCHAR(20)) AS Code FROM dbo.HR_FNSplitString_varchar(@Expression, '+')
		)
		SELECT @tmpDayNum = ISNULL(SUM(T.Coefficient), 0)
		FROM dbo.HR_PRSalCoeffEmp AS T WITH (NOLOCK) INNER JOIN tblA AS T1 ON T.CoeffCode = T1.Code
		WHERE T.EmployeeID = @EmployeeCode AND T.DowCode = @DowCode

		--SELECT @result = SUM(Amount) * @tmpDayNum
		--FROM HCSLS_BonusPickup_NJV WITH (NOLOCK) 
		--WHERE GroupCode = @GroupCode AND CoeffCode = @Expression and ConTypeCode = @tmpString
	END	
	ELSE IF @Type = 65
	BEGIN
		select top(1) @fBegDay = FromDate, @fEndDay = ToDate, @DowCode = DowCode from HR_ConfigTSEmpStandardWD WITH (NOLOCK) WHERE ToDate <= @ToTime and EmployeeID = @EmployeeCode order by FromDate DESC

		-- Lấy hợp đồng mới nhất còn hiệu lực.
		select @tmpString = R.ConTypeCode
		from (
			select A.ConTypeCode, ROW_NUMBER() OVER(ORDER BY A.ContFrom desc) as Row_ID, A.ContTo
			from dbo.HR_EmpContract as A with (nolock)
			where EmployeeID = @EmployeeCode and A.ContFrom <= @fEndDay
		) as R where Row_ID = 1 AND (R.ContTo IS NULL OR R.ContTo >= @fBegDay)

		;WITH tblA AS (
			SELECT CAST(LTRIM(RTRIM(data)) AS VARCHAR(20)) AS Code FROM dbo.HR_FNSplitString_varchar(@Expression, '+')
		)
		SELECT @result = COUNT(1) FROM tblA WHERE tblA.Code = @tmpString
	END
	ELSE IF @Type = 66
	BEGIN
		DECLARE @HotzoneCode VARCHAR(20)

		SELECT top(1) @fBegDay = FromDate, @fEndDay = ToDate, @DowCode = DowCode from HR_ConfigTSEmpStandardWD WITH (NOLOCK) WHERE ToDate <= @ToTime and EmployeeID = @EmployeeCode order by FromDate DESC
		SELECT TOP(1) @tmpString = A.AssignRegionCode FROM dbo.HR_EmployeeExt AS A WITH (NOLOCK) WHERE EmployeeID = @EmployeeCode
		SELECT TOP(1) @HotzoneCode = HotzoneCode FROM dbo.HR_LSRegion WITH (NOLOCK) WHERE RegionCode = @tmpString

		--SELECT @result = R.MinIncome
		--FROM (
		--	SELECT TOP(1) FromDate, ToDate, MinIncome
		--	FROM HCSLS_Hotzone WITH (NOLOCK) 
		--	WHERE HotzoneCode = @HotzoneCode and FromDate <= @fEndDay
		--) AS R WHERE R.ToDate IS NULL OR R.ToDate >= @fBegDay

	END
	ELSE IF @Type = 67
	BEGIN

		SELECT top(1) @fBegDay = FromDate, @fEndDay = ToDate, @DowCode = DowCode from HR_ConfigTSEmpStandardWD WITH (NOLOCK) WHERE ToDate <= @ToTime and EmployeeID = @EmployeeCode order by FromDate DESC
		SELECT TOP(1) @tmpString = A.AssignRegionCode FROM dbo.HR_EmployeeExt AS A WITH (NOLOCK) WHERE EmployeeID = @EmployeeCode
		SELECT TOP(1) @result = CoeffLaborProductivity FROM dbo.HR_LSRegion WITH (NOLOCK) WHERE RegionCode = @tmpString

	END
	ELSE IF @Type = 68
	BEGIN
		IF NOT EXISTS(SELECT TOP(1) 1 FROM dbo.HR_EmpTracking WITH (NOLOCK)
			WHERE EmployeeID = @EmployeeCode AND TableName = 'HR_Employees' AND FieldName = 'ProvinceCode')
		BEGIN
			SELECT TOP(1) @tmpString = ProvinceID FROM dbo.HR_Employees WITH (NOLOCK) WHERE EmployeeID = @EmployeeCode	
        END 
		ELSE
        BEGIN
			;WITH tblTmp AS (
				SELECT EffectDate, Value, ValueOld FROM HR_EmpTracking WITH (NOLOCK)
				WHERE EmployeeID = @EmployeeCode AND TableName = 'HR_Employees' AND FieldName = 'ProvinceCode'
			)
			SELECT @tmpString = CASE WHEN EffectDate <= @ToTime THEN Value else ValueOld end
			FROM (
				SELECT EffectDate, Value, ValueOld, ROW_NUMBER() OVER(ORDER BY EffectDate) as RowID
				FROM (
					SELECT TOP(1) A.EffectDate, A.Value, A.ValueOld FROM tblTmp AS A ORDER BY EffectDate ASC
					UNION ALL
					SELECT A.EffectDate, A.Value, A.ValueOld FROM tblTmp AS A WHERE A.EffectDate <= @ToTime
				) AS R
			) AS Z WHERE Z.RowID = 1
        END 

		;WITH tblA AS (
			SELECT CAST(LTRIM(RTRIM(data)) AS VARCHAR(20)) AS Code FROM dbo.HR_FNSplitString_varchar(@Expression, '+')
		)
		SELECT @result = COUNT(1) FROM tblA WHERE tblA.Code = @tmpString
	END
	ELSE IF @Type = 69
	BEGIN
		
		SELECT top(1) @DowCode = DowCode from HR_ConfigTSEmpStandardWD WITH (NOLOCK) 
		WHERE ToDate <= @ToTime and EmployeeID = @EmployeeCode order by FromDate DESC

		;with tblData as (
			select CAST([Data] AS VARCHAR(20)) AS Code from SplitStrings_CTE(@Expression, '+')
		)
		select @result = SUM(T.AmountTax)
		from HR_PayTExcept as T WITH (NOLOCK) inner join tblData as T1 on T.ExceptCode = T1.Code
		where T.EmployeeID = @EmployeeCode and T.DowCode = @DowCode
    END
	ELSE IF @Type = 70
	BEGIN
		select top(1) @fBegDay = FromDate, @fEndDay = ToDate, @DowCode = DowCode from HR_ConfigTSEmpStandardWD WITH (NOLOCK) WHERE ToDate <= @ToTime and EmployeeID = @EmployeeCode order by FromDate DESC

		-- Lấy hợp đồng mới nhất còn hiệu lực.
		select @tmpString = R.DisciplineCode
		from (
			select A.DisciplineCode, ROW_NUMBER() OVER(ORDER BY A.FromTime desc) as Row_ID, A.ToTime
			from dbo.HR_EmpDiscipline as A with (nolock)
			where EmployeeID = @EmployeeCode and A.FromTime <= @fEndDay
		) as R where Row_ID = 1 AND (R.ToTime IS NULL OR R.ToTime >= @fBegDay)

		;WITH tblA AS (
			SELECT CAST(LTRIM(RTRIM(data)) AS VARCHAR(20)) AS Code FROM dbo.HR_FNSplitString_varchar(@Expression, '+')
		)
		SELECT @result = COUNT(1) FROM tblA WHERE tblA.Code = @tmpString
	END
	ELSE IF @Type = 71
	BEGIN
		IF NOT EXISTS(SELECT TOP(1) 1 FROM dbo.HR_EmpTracking WITH (NOLOCK)
			WHERE EmployeeID = @EmployeeCode AND TableName = 'HR_EmployeeExt' AND FieldName = 'CurrencyCode')
		BEGIN
			SELECT TOP(1) @tmpString = CurrencyCode FROM dbo.HR_EmployeeExt WITH (NOLOCK) WHERE EmployeeID = @EmployeeCode	
        END 
		ELSE
        BEGIN
			;WITH tblTmp AS (
				SELECT EffectDate, Value, ValueOld FROM HR_EmpTracking WITH (NOLOCK)
				WHERE EmployeeID = @EmployeeCode AND TableName = 'HR_EmployeeExt' AND FieldName = 'CurrencyCode'
			)
			SELECT @tmpString = CASE WHEN EffectDate <= @ToTime THEN Value else ValueOld end
			FROM (
				SELECT EffectDate, Value, ValueOld, ROW_NUMBER() OVER(ORDER BY EffectDate) as RowID
				FROM (
					SELECT TOP(1) A.EffectDate, A.Value, A.ValueOld FROM tblTmp AS A ORDER BY EffectDate ASC
					UNION ALL
					SELECT A.EffectDate, A.Value, A.ValueOld FROM tblTmp AS A WHERE A.EffectDate <= @ToTime
				) AS R
			) AS Z WHERE Z.RowID = 1
        END 

		;WITH tblA AS (
			SELECT CAST(LTRIM(RTRIM(data)) AS VARCHAR(20)) AS Code FROM dbo.HR_FNSplitString_varchar(@Expression, '+')
		)
		SELECT @result = COUNT(1) FROM tblA WHERE tblA.Code = @tmpString
	END
	ELSE IF @Type = 72
	BEGIN
		IF NOT EXISTS(SELECT TOP(1) 1 FROM dbo.HR_EmpTracking WITH (NOLOCK)
			WHERE EmployeeID = @EmployeeCode AND TableName = 'HR_Employees' AND FieldName = 'WLeaveDayGroupCode')
		BEGIN
			SELECT TOP(1) @tmpString = WLeaveDayGroupCode FROM dbo.HR_EmployeeExt WITH (NOLOCK) WHERE EmployeeID = @EmployeeCode	
        END 
		ELSE
        BEGIN
			;WITH tblTmp AS (
				SELECT EffectDate, Value, ValueOld FROM HR_EmpTracking WITH (NOLOCK)
				WHERE EmployeeID = @EmployeeCode AND TableName = 'HR_Employees' AND FieldName = 'WLeaveDayGroupCode'
			)
			SELECT @tmpString = CASE WHEN EffectDate <= @ToTime THEN Value else ValueOld end
			FROM (
				SELECT EffectDate, Value, ValueOld, ROW_NUMBER() OVER(ORDER BY EffectDate) as RowID
				FROM (
					SELECT TOP(1) A.EffectDate, A.Value, A.ValueOld FROM tblTmp AS A ORDER BY EffectDate ASC
					UNION ALL
					SELECT A.EffectDate, A.Value, A.ValueOld FROM tblTmp AS A WHERE A.EffectDate <= @ToTime
				) AS R
			) AS Z WHERE Z.RowID = 1
        END 

		;WITH tblA AS (
			SELECT CAST(LTRIM(RTRIM(data)) AS VARCHAR(20)) AS Code FROM dbo.HR_FNSplitString_varchar(@Expression, '+')
		)
		SELECT @result = COUNT(1) FROM tblA WHERE tblA.Code = @tmpString
	END
	ELSE IF @Type = 73
	BEGIN
		IF NOT EXISTS(SELECT TOP(1) 1 FROM dbo.HR_EmpTracking WITH (NOLOCK)
			WHERE EmployeeID = @EmployeeCode AND TableName = 'HR_Employees' AND FieldName = 'JobID')
		BEGIN
			SELECT TOP(1) @tmpString = JobID FROM dbo.HR_Employees WITH (NOLOCK) WHERE EmployeeID = @EmployeeCode	
        END 
		ELSE
        BEGIN
			;WITH tblTmp AS (
				SELECT EffectDate, Value, ValueOld FROM HR_EmpTracking WITH (NOLOCK)
				WHERE EmployeeID = @EmployeeCode AND TableName = 'HR_Employees' AND FieldName = 'JobID'
			)
			SELECT @tmpString = CASE WHEN EffectDate <= @ToTime THEN Value else ValueOld end
			FROM (
				SELECT EffectDate, Value, ValueOld, ROW_NUMBER() OVER(ORDER BY EffectDate desc) as RowID
				FROM (
					SELECT TOP(1) A.EffectDate, A.Value, A.ValueOld FROM tblTmp AS A ORDER BY EffectDate ASC
					UNION ALL
					SELECT A.EffectDate, A.Value, A.ValueOld FROM tblTmp AS A WHERE A.EffectDate <= @ToTime
				) AS R
			) AS Z WHERE Z.RowID = 1
        END 
		
		--select top(1) @result = isnull(CBI, 0) from HR_Positions with (nolock) where JobID = @tmpString

		SET @result = ISNULL(@result, 0)

	END
	ELSE IF @Type = 74
	BEGIN
		SELECT TOP(1) @DowCode = DowCode FROM dbo.HR_ConfigTSEmpStandardWD with (nolock) WHERE EmployeeID = @EmployeeCode AND FromDate <= @ToTime ORDER BY FromDate desc
		SELECT top(1) @result = SalaryIns FROM HR_SocialIns WITH (NOLOCK) WHERE DowCode = @DowCode AND EmployeeID = @EmployeeCode

	END
	ELSE IF @Type = 75
	BEGIN
		select top(1) @fBegDay = FromDate, @fEndDay = ToDate from HR_ConfigTSEmpStandardWD where DowCode = @DowCode and EmployeeID = @EmployeeCode

		;with tblAlloGrade as (
			select B.AlloGradeCode, B.IsFixAmount from HR_FNSplitString_varchar(@Expression, '+') as A inner join HR_LSAlloGrade as B on ltrim(rtrim(A.[data])) = B.AlloGradeCode
		)
		select @result = sum(Amount)
		from (
			select AG.AlloGradeCode as ID, case when AG.IsFixAmount = 1 then A.FixAmount else A.SalaryRate end as Amount,
				ROW_NUMBER() OVER(PARTITION BY AG.AlloGradeCode ORDER BY EffectDate desc) as Row_ID
			from HR_EmpAllowance as A with (nolock) inner join tblAlloGrade as AG WITH (NOLOCK) on A.AlloGradeCode = AG.AlloGradeCode
			where EmployeeID = @EmployeeCode and 
				(EffectDate <= @fEndDay and (EndDate = '' OR EndDate IS NULL OR EndDate > @ToTime))
		) as R where Row_ID = 1
	END
	ELSE IF @Type = 76
	BEGIN
		SELECT TOP(1) @result = ISNULL(WorkingStatus,0) FROM HR_EmployeeExt WITH (NOLOCK) WHERE EmployeeID = @EmployeeCode
	END
	ELSE IF @Type = 77
	BEGIN
		SELECT top(1) @DowCode = DowCode FROM HR_ConfigTSEmpStandardWD WITH (NOLOCK)
		WHERE FromDate <= @ToTime and EmployeeID = @EmployeeCode order by FromDate desc

		declare @V float, @U float

		-- Lay gia tri thu nhap khac trong TExcepts
		;WITH LData AS (
			SELECT RTRIM(LTRIM(data)) AS Code FROM HR_FNSplitString_varchar(@Expression, '+')
		)
		select @V = sum(NBKL), @U = Sum(NKLT)
		from (
			SELECT case when T.ExceptCode = 'NBKL' then T.Amount else 0 end as NBKL,
				case when T.ExceptCode = 'NKLT' then T.Amount else 0 end as NKLT
			FROM HR_PayTExcept as T WITH (NOLOCK) INNER JOIN LData AS T1 ON T.ExceptCode = T1.Code
			WHERE T.EmployeeID = @EmployeeCode AND DowCode = @DowCode
		) as R

		/*
			IF(AND(V>=4;>=0);0%;
IF(AND(V=3;U>0;<=2);25%;
IF(AND(V=3;U=0);50%;
IF(AND(V=2;U=3);50%;

IF(AND(V=2;U<=2);75%;
IF(AND(V=1;U=4);50%;
IF(AND(V=1;U<=3);100%;
IF(AND(V=0;U=5);50%;
IF(AND(V=0;U<=4);100%;0%)))))))))
		*/

		if @V >= 4 and @U >= 0 
			set @result = 0
		else if @V = 3 and @U >0 and @U <= 2
			set @result = 25
		else if @V = 3 and @U = 0
			set @result = 50
		else if @V = 2 and @U = 3
			set @result = 50
		else if @V = 2 and @U <= 2
			set @result = 75
		else if @V = 1 and @U = 4
			set @result = 50
		else if @V = 1 and @U <= 3
			set @result = 100
		else if @V = 0 and @U = 5
			set @result = 50
		else if @V = 0 and @U <= 4
			set @result = 100
		else
			set @result = 0
	END
	
	SET @result = ISNULL(@result, 0)
	return @result

END


---------------------6
USE [codx_hr]
GO
/****** Object:  UserDefinedFunction [dbo].[HR_fnFGetHT_LayThongTinBatKyTheoBP]    Script Date: 2/7/2025 6:32:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER FUNCTION [dbo].[HR_fnFGetHT_LayThongTinBatKyTheoBP](
	@DepartmentCode NVARCHAR(20),
	@DowCode VARCHAR(7),
	@ToTime datetime = '2015-11-25',
	@Expression varchar(max) = '',
	@Type int
)
RETURNS float
AS
BEGIN
	declare @result FLOAT, @Year INT, @Quarter INT, @FromTime DATETIME
	DECLARE @RegionCode VARCHAR(20)
	SET @Year = CAST(LEFT(@DowCode, 4) AS INT)
	SET @Expression = LTRIM(RTRIM(@Expression))

	IF @Type = 1
	BEGIN
		-- Lấy giá trị mặc định của hệ số lương thưởng
		;WITH LData AS (
			SELECT RTRIM(LTRIM(data)) AS Code FROM HR_FNSplitString_varchar(@Expression, '+')
		)
		SELECT @result = SUM(T.DefaultValue)
		FROM HR_LSSalCoeff as T WITH (NOLOCK) INNER JOIN LData AS T1 ON T.CoeffCode = T1.Code
    END
    ELSE IF @Type = 4
	BEGIN
	-- Chưa chuyển HCSPR_SalCoeffDept
		-- Lấy giá trị mặc định của hệ số lương thưởng theo bo phan
		--;WITH LData AS (
		--	SELECT RTRIM(LTRIM(data)) AS Code FROM HR_FNSplitString_varchar(@Expression, '+')
		--)
		--SELECT @result = SUM(T.Coefficient)
		--FROM HCSPR_SalCoeffDept as T WITH (NOLOCK) INNER JOIN LData AS T1 ON T.CoeffCode = T1.Code
		--WHERE T.DepartmentCode = @DepartmentCode AND T.DowCode = @DowCode
		SELECT @result = @result -- Thêm vào để tránh lỗi => Chuyển bảng HCSPR_SalCoeffDept thì xóa dòng này
	END
	ELSE IF @Type = 5
	BEGIN
		SET @Quarter = DATEPART(QUARTER, @DowCode + '/01')
		-- Lấy giá trị mặc định của hệ số lương thưởng theo bo phan theo quy
		-- Chưa chuyển HCSPR_SalCoeffMonth
		--;WITH LData AS (
		--	SELECT RTRIM(LTRIM(data)) AS Code FROM HR_FNSplitString_varchar(@Expression, '+')
		--), LQuarter AS (
		--	SELECT DowCode
		--	FROM (
		--		SELECT DowCode, DATEPART(QUARTER, DowCode + '/01') AS mQuarter 
		--		FROM HR_LSPayrollDow WITH (NOLOCK) WHERE LEFT(DowCode, 4) = @Year
		--	) AS R WHERE mQuarter = @Quarter
		--)
		--SELECT @result = SUM(T.Coefficient)
		--FROM HCSPR_SalCoeffMonth as T WITH (NOLOCK) INNER JOIN LData AS T1 ON T.CoeffCode = T1.Code
		--	INNER JOIN LQuarter AS T2 ON T.DowCode = T2.DowCode
		--WHERE T.DepartmentCode = @DepartmentCode
	END
	ELSE IF @Type = 6
	BEGIN
		
		SET @Expression = LTRIM(RTRIM(@Expression))
		SELECT TOP(1) @RegionCode = RegionID FROM HR_OrganizationUnits WITH (NOLOCK) WHERE OrgUnitID = @DepartmentCode
		IF @Expression = @RegionCode
			SET @result = 1
		ELSE
			SET @result = 0
    END
    ELSE IF @Type = 7
	BEGIN
		SELECT @result = SUM(T2.Amount)
		FROM HR_FNGetChildDepartments(@DepartmentCode) AS T INNER JOIN HR_Employees AS T1 WITH (NOLOCK) ON T.DepartmentCode = T1.OrgUnitID
			INNER JOIN HR_PaySalary AS T2 WITH (NOLOCK) ON T1.EmployeeID = T2.EmployeeID
		WHERE T2.DowCode = @DowCode
    END
    ELSE IF @Type = 8
	BEGIN		
		;WITH LData AS (
			SELECT RTRIM(LTRIM(data)) AS Code FROM HR_FNSplitString_varchar(@Expression, '+')
		), tblDepartment AS (
			SELECT DepartmentCode FROM HR_FNGetChildDepartments(@DepartmentCode)
		)
		SELECT @result = SUM(T.DayNum)
		FROM HR_TSKowDs as T WITH (NOLOCK) 
			INNER JOIN LData AS T1 ON T.KowCode = T1.Code
			INNER JOIN HR_Employees AS T2 WITH (NOLOCK) ON T.EmployeeID = T2.EmployeeID
			INNER JOIN tblDepartment AS T3 ON T2.OrgUnitID = T3.DepartmentCode
		WHERE T.DowCode = @DowCode AND T.IsPay = 0
	END
	ELSE IF @Type = 9
	BEGIN		
		;WITH LData AS (
			SELECT RTRIM(LTRIM(data)) AS Code FROM HR_FNSplitString_varchar(@Expression, '+')
		), tblDepartment AS (
			SELECT DepartmentCode FROM HR_FNGetChildDepartments(@DepartmentCode)
		)
		SELECT @result = SUM(T.DayNum)
		FROM HR_TSKowDs as T WITH (NOLOCK) 
			INNER JOIN LData AS T1 ON T.KowCode = T1.Code
			INNER JOIN HR_Employees AS T2 WITH (NOLOCK) ON T.EmployeeID = T2.EmployeeID
			INNER JOIN tblDepartment AS T3 ON T2.OrgUnitID = T3.DepartmentCode
		WHERE T.DowCode = @DowCode AND DATEPART(DW, T.WorkDate) = 1 AND T.IsPay = 0
	END
	ELSE IF @Type = 10
	BEGIN		
		;WITH LData AS (
			SELECT RTRIM(LTRIM(data)) AS Code FROM HR_FNSplitString_varchar(@Expression, '+')
		), tblDepartment AS (
			SELECT DepartmentCode FROM HR_FNGetChildDepartments(@DepartmentCode)
		)
		SELECT @result = SUM(T.DayNum)
		FROM HR_PaySalary as T WITH (NOLOCK) 
			INNER JOIN LData AS T1 ON T.KowCode = T1.Code
			INNER JOIN HR_Employees AS T2 WITH (NOLOCK) ON T.EmployeeID = T2.EmployeeID
			INNER JOIN tblDepartment AS T3 ON T2.OrgUnitID = T3.DepartmentCode
		WHERE T.DowCode = @DowCode
	END
	ELSE IF @Type = 11
	BEGIN		
		;WITH tblDepartment AS (
			SELECT DepartmentCode FROM HR_FNGetChildDepartments(@DepartmentCode)
		)
		SELECT @result = SUM(T.TotalKowSal)
		FROM HR_PayIncome as T WITH (NOLOCK) 
			INNER JOIN tblDepartment AS T1 ON T.OrgUnitID = T1.DepartmentCode
		WHERE T.DowCode = @DowCode
	END
	ELSE IF @Type = 12
	BEGIN		
		select top(1) @DowCode = DowCode from HR_LSPayrollDow where BegDay < @ToTime order by DowCode DESC
        -- Chưa chuyển HCSPR_SalCoeffDept
		--;WITH LData AS (
		--	SELECT RTRIM(LTRIM(data)) AS Code FROM HR_FNSplitString_varchar(@Expression, '+')
		--)
		--SELECT @result = SUM(T.Coefficient)
		--FROM HCSPR_SalCoeffDept as T WITH (NOLOCK) INNER JOIN LData AS T1 ON T.CoeffCode = T1.Code
		--WHERE T.DepartmentCode = @DepartmentCode AND T.DowCode = @DowCode
	END
	ELSE IF @Type = 13
	BEGIN		
		;WITH LData AS (
			SELECT RTRIM(LTRIM(data)) AS Code FROM HR_FNSplitString_varchar(@Expression, '+')
		), tblDepartment AS (
			SELECT DepartmentCode FROM HR_FNGetChildDepartments(@DepartmentCode)
		)
		SELECT @result = SUM(T.Amount) -- Cát lợi
		FROM HR_PaySalary as T WITH (NOLOCK) 
			INNER JOIN LData AS T1 ON T.KowCode = T1.Code
			INNER JOIN HR_Employees AS T2 WITH (NOLOCK) ON T.EmployeeID = T2.EmployeeID
			INNER JOIN tblDepartment AS T3 ON T2.OrgUnitID = T3.DepartmentCode
		WHERE T.DowCode = @DowCode
	END
	ELSE IF @Type = 14
	BEGIN		
		;WITH tblDepartment AS (
			SELECT DepartmentCode FROM HR_FNGetChildDepartments(@DepartmentCode)
		)
		 select @result = sum(RealSalary)
        from (
            select RealSalary,
				ROW_NUMBER() OVER(PARTITION BY A.EmployeeID ORDER BY A.EffectDate desc) as Row_ID 
            from HR_EmpJWSalary as A with (nolock) inner join HR_Employees as T1 with (nolock) on A.EmployeeID = T1.EmployeeID
				inner join tblDepartment as T2 on T1.OrgUnitID = T2.DepartmentCode
            where (A.EffectDate <= @ToTime and (EndDate = '' OR EndDate IS NULL OR EndDate > @ToTime))
        ) as R where Row_ID = 1
	END
	ELSE IF @Type = 15
	BEGIN		
		select top(1) @DowCode = DowCode from HR_LSPayrollDow where BegDay <= @ToTime order by DowCode DESC
		;WITH LData AS (
			SELECT RTRIM(LTRIM(data)) AS Code FROM HR_FNSplitString_varchar(@Expression, '+')
		), tblDepartment AS (
			SELECT DepartmentCode FROM HR_FNGetChildDepartments(@DepartmentCode)
		)
		SELECT @result = SUM(T.Coefficient)
		FROM HR_PRSalCoeffEmp as T WITH (NOLOCK) 
			INNER JOIN LData AS T1 ON T.CoeffCode = T1.Code
			INNER JOIN tblDepartment AS T3 ON T.OrgUnitID = T3.DepartmentCode
		WHERE T.DowCode = @DowCode
	END
	ELSE IF @Type = 16
	BEGIN		
		select top(1) @DowCode = DowCode from HR_LSPayrollDow where BegDay <= @ToTime order by DowCode DESC
		;WITH LData AS (
			SELECT RTRIM(LTRIM(data)) AS Code FROM HR_FNSplitString_varchar(@Expression, '+')
		), tblDepartment AS (
			SELECT DepartmentCode FROM HR_FNGetChildDepartments(@DepartmentCode)
		)
		SELECT @result = SUM(T.Amount)
		FROM HR_PayTExcept as T WITH (NOLOCK) 
			INNER JOIN LData AS T1 ON T.ExceptCode = T1.Code
			inner join HR_Employees as T2 on T.EmployeeID = T2.EmployeeID
			INNER JOIN tblDepartment AS T3 ON T2.OrgUnitID = T3.DepartmentCode
		WHERE T.DowCode = @DowCode
	END
	ELSE IF @Type = 17
	BEGIN
		SELECT TOP(1) @FromTime = BegDay FROM HR_LSPayrollDow WHERE BegDay <= @ToTime ORDER BY DowCode DESC
        
		-- còn dang lam viec tinh den cuoi ky cong
		SELECT @result = COUNT(*)
		FROM HR_Employees AS T WITH (NOLOCK)
		WHERE T.OrgUnitID = @DepartmentCode 
			AND ((T.StoppedOn IS NULL) OR (T.StoppedOn IS NOT NULL AND T.StoppedOn > @FromTime))
			AND T.JoinedOn <= @ToTime

    END
	ELSE IF @Type = 18
	BEGIN
		SELECT TOP(1) @FromTime = BegDay FROM HR_LSPayrollDow WHERE BegDay <= @ToTime ORDER BY DowCode DESC

		-- còn dang lam viec tinh den cuoi ky cong
		;WITH tblDeps AS (
			SELECT DepartmentCode FROM HR_FNGetChildDepartments(@DepartmentCode)
		)
		SELECT @result = COUNT(*)
		FROM HR_Employees AS T WITH (NOLOCK)
			INNER JOIN tblDeps AS T2 ON T.OrgUnitID = T2.DepartmentCode
		WHERE ((T.StoppedOn IS NULL) OR (T.StoppedOn IS NOT NULL AND T.StoppedOn > @FromTime))
			AND T.JoinedOn <= @ToTime
    END
	ELSE IF @Type = 19
	BEGIN
		-- LẤY ĐỊNH BIÊN KẾ HOẠCH XÂY DỰNG ĐẦU NĂM THEO PHÒNG BAN
		-- Chưa chuyển TASAT_Headcount
		--SELECT @result = SUM(Planning)
		--FROM TASAT_Headcount WITH (NOLOCK)
		--WHERE DepartmentCode = @DepartmentCode AND YearID = YEAR(@ToTime)
		set @result = @result -- Chuyển bảng xong xóa dòng này
    END
	ELSE IF @Type = 20
	BEGIN
		-- LẤY ĐỊNH BIÊN KẾ HOẠCH XÂY DỰNG ĐẦU NĂM THEO PHÒNG BAN
		-- Chưa chuyển TASAT_Headcount
		--;WITH tblDeps AS (
		--	SELECT DepartmentCode FROM HR_FNGetChildDepartments(@DepartmentCode)
		--)
		--SELECT @result = SUM(Planning)
		--FROM TASAT_Headcount AS T WITH (NOLOCK) INNER JOIN tblDeps AS T1 ON T.DepartmentCode = T1.DepartmentCode
		--WHERE YearID = YEAR(@ToTime)
		set @result = @result -- Chuyển bảng xong xóa dòng này
    END
	ELSE IF @Type = 21
	BEGIN
		select top(1) @DowCode = DowCode from HR_LSPayrollDow where BegDay < @ToTime order by DowCode DESC
        SELECT TOP(1) @RegionCode = RegionID FROM HR_OrganizationUnits WITH (NOLOCK) WHERE OrgUnitID = @DepartmentCode

		-- Chưa chuyển HCSPR_SalCoeffDept
		--;WITH LData AS (
		--	SELECT RTRIM(LTRIM(data)) AS Code FROM HR_FNSplitString_varchar(@Expression, '+')
		--)
		--SELECT @result = SUM(T.Coefficient)
		--FROM HCSPR_SalCoeffDept as T WITH (NOLOCK) INNER JOIN LData AS T1 ON T.CoeffCode = T1.Code
		--WHERE T.DowCode = @DowCode and T.DepartmentCode = @RegionCode

		SELECT @result = @result / count(1) from HR_FNGetChildDepartments(@RegionCode) where DepartmentCode <> @RegionCode
    END 
	ELSE IF @Type = 22
	BEGIN
		select top(1) @DowCode = DowCode from HR_LSPayrollDow where BegDay < @ToTime order by DowCode DESC
        SELECT TOP(1) @RegionCode = RegionID FROM HR_OrganizationUnits WITH (NOLOCK) WHERE OrgUnitID = @DepartmentCode

		-- Chưa chuyển HCSPR_SalCoeffMonth
		--;WITH LData AS (
		--	SELECT RTRIM(LTRIM(data)) AS Code FROM HR_FNSplitString_varchar(@Expression, '+')
		--)
		--SELECT @result = SUM(T.Coefficient)
		--FROM dbo.HCSPR_SalCoeffMonth as T WITH (NOLOCK) INNER JOIN LData AS T1 ON T.CoeffCode = T1.Code
		--WHERE T.DowCode = @DowCode and T.DepartmentCode = @RegionCode

		SELECT @result = @result / count(1) from HR_FNGetChildDepartments(@RegionCode) where DepartmentCode <> @RegionCode
    END 
	ELSE IF @Type = 23
	BEGIN
		select top(1) @DowCode = DowCode from HR_LSPayrollDow where BegDay < @ToTime order by DowCode DESC
		-- Chưa chuyển view HCSSYS_VWDepartmentFullInfo, HCSPR_SalCoeffDept
        -- SELECT TOP(1) @RegionCode = CAP2_Code FROM HCSSYS_VWDepartmentFullInfo WITH (NOLOCK) WHERE DepartmentCode = @DepartmentCode

		--;WITH LData AS (
		--	SELECT RTRIM(LTRIM(data)) AS Code FROM HR_FNSplitString_varchar(@Expression, '+')
		--)
		--SELECT @result = SUM(T.Coefficient)
		--FROM HCSPR_SalCoeffDept as T WITH (NOLOCK) INNER JOIN LData AS T1 ON T.CoeffCode = T1.Code
		--WHERE T.DowCode = @DowCode and T.DepartmentCode = @RegionCode

		SELECT @result = @result / count(1) from HR_FNGetChildDepartments(@RegionCode) where DepartmentCode <> @RegionCode
    END 
	ELSE IF @Type = 24
	BEGIN
		select top(1) @DowCode = DowCode from HR_LSPayrollDow where BegDay < @ToTime order by DowCode DESC
		-- Chưa chuyển view HCSSYS_VWDepartmentFullInfo, HCSPR_SalCoeffMonth
  --      SELECT TOP(1) @RegionCode = CAP2_Code FROM HCSSYS_VWDepartmentFullInfo WITH (NOLOCK) WHERE DepartmentCode = @DepartmentCode

		--;WITH LData AS (
		--	SELECT RTRIM(LTRIM(data)) AS Code FROM HR_FNSplitString_varchar(@Expression, '+')
		--)
		--SELECT @result = SUM(T.Coefficient)
		--FROM dbo.HCSPR_SalCoeffMonth as T WITH (NOLOCK) INNER JOIN LData AS T1 ON T.CoeffCode = T1.Code
		--WHERE T.DowCode = @DowCode and T.DepartmentCode = @RegionCode

		SELECT @result = @result / count(1) from HR_FNGetChildDepartments(@RegionCode) where DepartmentCode <> @RegionCode
    END 

	SET @result = ISNULL(@result, 0)
	return @result

END



-----------------7
USE [codx_hr]
GO
/****** Object:  UserDefinedFunction [dbo].[HR_fnFGetHT_LayThongTinBatKyTheoBPV2]    Script Date: 2/7/2025 6:32:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER FUNCTION [dbo].[HR_fnFGetHT_LayThongTinBatKyTheoBPV2](
	@DepartmentCode NVARCHAR(20),
	@DowCode VARCHAR(7),
	@ToTime datetime = '2015-11-25',
	@Expression varchar(max) = '',
	@Expression2 NVARCHAR(MAX) = '',
	@Type int
)
RETURNS float
AS
BEGIN
	declare @result FLOAT

	IF @Type = 1
	BEGIN
		select top(1) @DowCode = DowCode from HR_LSPayrollDow where BegDay <= @ToTime order by DowCode DESC
		-- Lấy giá trị mặc định của hệ số lương thưởng
		-- Chưa chuyển HCSPR_SalCoeffDept
		--;WITH LData AS (
		--	SELECT RTRIM(LTRIM(data)) AS Code FROM SplitStrings_CTE(@Expression, '+')
		--), LDepartment AS (
		--	SELECT RTRIM(LTRIM(data)) AS Code FROM SplitStrings_CTE(@Expression2, '+')
		--)
		--SELECT @result = SUM(T.Coefficient)
		--FROM HCSPR_SalCoeffDept AS T WITH (NOLOCK) 
		--	INNER JOIN LData AS T1 ON T.CoeffCode = T1.Code
		--	INNER JOIN LDepartment AS T2 ON T.DepartmentCode = T2.Code
		--WHERE DowCode = @DowCode
    END
	ELSE IF @Type = 2
	BEGIN
		select top(1) @DowCode = DowCode from HR_LSPayrollDow where BegDay <= @ToTime order by DowCode DESC
		-- Lấy giá trị mặc định của hệ số lương thưởng
		-- Chưa chuyển HCSPR_SalCoeffDept
		--;WITH LData AS (
		--	SELECT RTRIM(LTRIM(data)) AS Code FROM SplitStrings_CTE(@Expression, '+')
		--), LDepartment AS (
		--	SELECT RTRIM(LTRIM(data)) AS Code FROM SplitStrings_CTE(@Expression2, '+')
		--)
		--SELECT @result = AVG(T.Coefficient)
		--FROM HCSPR_SalCoeffDept AS T WITH (NOLOCK) 
		--	INNER JOIN LData AS T1 ON T.CoeffCode = T1.Code
		--	INNER JOIN LDepartment AS T2 ON T.DepartmentCode = T2.Code
		--WHERE DowCode = @DowCode
    END
	ELSE IF @Type = 3
	BEGIN
	-- Chưa chuyển HCSPR_ProductDeptMonth, HCSLS_ProductDetail
		--SELECT @result = SUM(Quantity * Amount)
		--FROM (
		--	select ProductCode, CASE @Expression WHEN 'SLSanPham_A' then Quantity WHEN 'SLSanPham_B' then QuantityB WHEN 'SLSanPham_C' then QuantityC WHEN 'SLSanPham_D' then QuantityD ELSE 0 END AS Quantity
		--	from HCSPR_ProductDeptMonth as M WITH (NOLOCK) 
		--	where DowCode = @DowCode and DepartmentCode = @DepartmentCode
		--) AS T INNER JOIN (
		--	select ProductCode, CASE @Expression2 WHEN 'DGSanPham_A' then Amount WHEN 'DGSanPham_B' then AmountB WHEN 'DGSanPham_C' then AmountC WHEN 'DGSanPham_D' then AmountD ELSE 0 END AS Amount
		--	from (
		--		select ProductCode, Amount, AmountB, AmountC, AmountD, 
		--			ROW_NUMBER() OVER(PARTITION BY ProductCode ORDER BY ProductCode, DateID desc) as Row_ID
		--		from HCSLS_ProductDetail WITH (NOLOCK) where DateID <= @ToTime
		--	) as ce where Row_ID = 1
		--) AS T1 ON T.ProductCode = T1.ProductCode
		set @result = ISNULL(@result, 0)
	END

	SET @result = ISNULL(@result, 0)
	return @result

END


---------------------8
USE [codx_hr]
GO
/****** Object:  UserDefinedFunction [dbo].[HR_fnFGetHT_LayThongTinBatKyV2]    Script Date: 2/7/2025 6:33:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER FUNCTION [dbo].[HR_fnFGetHT_LayThongTinBatKyV2](
	@EmployeeCode NVARCHAR(20) = 'Y181024001',
	@DowCode VARCHAR(7) = '2018/01',
	@FromTime DATETIME = '2017/01/01',
	@ToTime datetime = '2017/12/31',
	@Expression varchar(max) = 'LKTT',
	@Type int = 2
)
RETURNS float
AS
BEGIN
	declare @result float, @JoinDate DATETIME, @EndDate DATETIME, @tmpStrValue varchar(20), @tmpDateTime datetime
	declare @orgFromTime datetime, @orgToTime datetime, @WLeaveDayValue int, @tmpStrValueOLD varchar(20)

	set @result = 0
	set @Expression = ltrim(rtrim(@Expression))
	SELECT @JoinDate = JoinedOn, @EndDate = StoppedOn  FROM HR_Employees WITH (NOLOCK) WHERE EmployeeID = @EmployeeCode
	set @orgFromTime = @FromTime
	set @orgToTime = @ToTime

	SET @FromTime = CASE WHEN @FromTime <= @JoinDate THEN @JoinDate ELSE @FromTime END 
	-- 
	IF @EndDate IS NOT NULL
		SET @ToTime = CASE WHEN @ToTime < @EndDate THEN @ToTime ELSE @EndDate END 

	-- Đếm số tháng
	IF @Type = 1
	BEGIN
		SELECT @result = COUNT(*)
		FROM HR_ConfigTSEmpStandardWD WITH (NOLOCK)
		WHERE EmployeeID = @EmployeeCode AND FromDate <= @ToTime AND @FromTime <= ToDate
    END

	-- Tong thu nhap khác
    ELSE IF @Type = 2 
	BEGIN
		WITH tblData as (
			SELECT ltrim(rtrim(CAST(Data AS VARCHAR))) AS Code
			FROM SplitStrings_CTE(@Expression, '+')
		), tblEmpStandardWD AS (
			SELECT DowCode
			FROM HR_ConfigTSEmpStandardWD WITH (NOLOCK)
			WHERE EmployeeID = @EmployeeCode AND FromDate <= @ToTime AND @FromTime <= ToDate
		)
		SELECT @result = SUM(T.Amount)
		FROM HR_PayTExcept AS T WITH (NOLOCK)
			INNER JOIN tblEmpStandardWD AS T1 ON T.DowCode = T1.DowCode
			INNER JOIN tblData AS T2 ON T.ExceptCode = T2.Code
		WHERE T.EmployeeID = @EmployeeCode
    END
    
	-- Tong luong theo cong
    ELSE IF @Type = 3 
	BEGIN
		WITH tblData as (
			SELECT ltrim(rtrim(CAST(Data AS VARCHAR))) AS Code
			FROM SplitStrings_CTE(@Expression, '+')
		), tblEmpStandardWD AS (
			SELECT DowCode
			FROM HR_ConfigTSEmpStandardWD WITH (NOLOCK)
			WHERE EmployeeID = @EmployeeCode AND FromDate <= @ToTime AND @FromTime <= ToDate
		)
		SELECT @result = SUM(T.Amount)
		FROM HR_PaySalary AS T WITH (NOLOCK)
			INNER JOIN tblEmpStandardWD AS T1 ON T.DowCode = T1.DowCode
			INNER JOIN tblData AS T2 ON T.KowCode = T2.Code
		WHERE T.EmployeeID = @EmployeeCode
    END

	-- Tong phu cap
    ELSE IF @Type = 4 
	BEGIN
		WITH tblData as (
			SELECT ltrim(rtrim(CAST(Data AS VARCHAR))) AS Code
			FROM SplitStrings_CTE(@Expression, '+')
		), tblEmpStandardWD AS (
			SELECT DowCode
			FROM HR_ConfigTSEmpStandardWD WITH (NOLOCK)
			WHERE EmployeeID = @EmployeeCode AND FromDate <= @ToTime AND @FromTime <= ToDate
		)
		SELECT @result = SUM(T.Amount)
		FROM HR_PayAllowance AS T WITH (NOLOCK)
			INNER JOIN tblEmpStandardWD AS T1 ON T.DowCode = T1.DowCode
			INNER JOIN tblData AS T2 ON T.AlloGradeCode = T2.Code
		WHERE T.EmployeeID = @EmployeeCode
    END

	-- Tong bua an
	-- Chưa chuyển HCSEM_EmpMeal
 --   ELSE IF @Type = 5 
	--BEGIN
	--	SELECT @result = COUNT(1)
	--	FROM HCSEM_EmpMeal WITH (NOLOCK)
	--	WHERE EmployeeCode = @EmployeeCode AND WorkDate BETWEEN @FromTime AND @ToTime
 --   END
	ELSE IF @Type = 6
	BEGIN
		WITH tblData as (
			SELECT ltrim(rtrim(CAST(Data AS VARCHAR(20)))) AS Code
			FROM SplitStrings_CTE(@Expression, '+')
		)
		SELECT @result = SUM(T.Coefficient)
		FROM dbo.HR_PRSalCoeffEmp AS T WITH (NOLOCK) INNER JOIN tblData AS T1 ON T.CoeffCode = T1.Code
		WHERE EmployeeID = @EmployeeCode AND @FromTime <= T.ToTime AND T.FromTime <= @ToTime
    END
	else if @type = 7
	begin
		WITH tblData as (
			SELECT ltrim(rtrim(CAST(Data AS VARCHAR(20)))) AS Code
			FROM SplitStrings_CTE(@Expression, '+')
		)
		select @result = count(1)
		from HR_EmpDiscipline as T with (nolock) 
			inner join tblData as T1 with (nolock) on T.DisciplineCode = T1.Code
		where T.DecisionDate between @FromTime and @ToTime and T.EmployeeID = @EmployeeCode
	end
	else if @type = 8
	begin
		IF NOT EXISTS(SELECT TOP(1) 1 FROM dbo.HR_EmpTracking WITH (NOLOCK)
			WHERE EmployeeID = @EmployeeCode AND TableName = 'HR_Employees' AND FieldName = 'WLeaveDayGroupCode')
		BEGIN
			--
			select top(1) @result = StandardWD
			FROM HR_ConfigTSEmpStandardWD WITH (NOLOCK) WHERE EmployeeID = @EmployeeCode AND FromDate <= @orgToTime
			order by FromDate desc
        END 
		ELSE
        BEGIN
			;WITH tblTmp AS (
				SELECT EffectDate, Value, ValueOld FROM HR_EmpTracking WITH (NOLOCK)
				WHERE EmployeeID = @EmployeeCode AND TableName = 'HR_Employees' AND FieldName = 'WLeaveDayGroupCode'
			)
			SELECT @tmpStrValue = CASE WHEN EffectDate <= @ToTime THEN Value else ValueOld end, @tmpDateTime = EffectDate,
				@tmpStrValueOld = CASE WHEN EffectDate <= @ToTime THEN ValueOld else Value end
			FROM (
				SELECT EffectDate, Value, ValueOld, ROW_NUMBER() OVER(ORDER BY EffectDate) as RowID
				FROM (
					SELECT TOP(1) A.EffectDate, A.Value, A.ValueOld FROM tblTmp AS A ORDER BY EffectDate ASC
					UNION ALL
					SELECT A.EffectDate, A.Value, A.ValueOld FROM tblTmp AS A WHERE A.EffectDate <= @ToTime
				) AS R
			) AS Z WHERE Z.RowID = 1

			/*
				1;Nghỉ Thứ 7 và Chủ nhật;
				2;Nghỉ Chủ nhật;
				3;Nghỉ nữa ngày Thứ 7 và 1 ngày Chủ nhật;
				4;Nghỉ vào ngày bất kỳ trong tuần;
				5;Nghỉ chiều thứ 7 và ngày bất kỳ trong tuần
			*/
			select top(1) @WLeaveDayValue = WLeaveDayValue
			from HR_LSWLeaveDayGroup with (nolock) where WLeaveDayGroupCode = @tmpStrValueOld

			-- Xử lý quyết định 1
			set @tmpDateTime = @tmpDateTime - 1
			select @result = @result + datediff(day, @FromTime, @tmpDateTime) + 1 + dbo.HR_fnFGetHT_DemNgayNghiTheoQuyDinh(@EmployeeCode, @DowCode, @WLeaveDayValue, @FromTime, @tmpDateTime)

			select top(1) @WLeaveDayValue = WLeaveDayValue
			from HR_LSWLeaveDayGroup with (nolock) where WLeaveDayGroupCode = @tmpStrValue

			-- Xử lý quyết định 2
			set @tmpDateTime = @tmpDateTime + 1
			select @result = @result + datediff(day, @tmpDateTime, @ToTime) + 1 + dbo.HR_fnFGetHT_DemNgayNghiTheoQuyDinh(@EmployeeCode, @DowCode, @WLeaveDayValue, @tmpDateTime, @ToTime)

        END 
	end

	SET @result = ISNULL(@result, 0)
	return @result


END


--------------------------9
USE [codx_hr]
GO
/****** Object:  UserDefinedFunction [dbo].[HR_fnFGetHT_LayThongTinBatKyV3]    Script Date: 2/7/2025 6:33:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER FUNCTION [dbo].[HR_fnFGetHT_LayThongTinBatKyV3](
	@EmployeeCode NVARCHAR(20),
	@DowCode VARCHAR(7),
	@Expression NVARCHAR(200),
	@Type int
)
RETURNS NVARCHAR(200)
AS
BEGIN
	declare @result NVARCHAR(200)
    SET @Expression = LTRIM(RTRIM(@Expression))

	IF @Type = 1
	BEGIN
		SELECT TOP(1) @result = RegionID
		FROM HR_OrganizationUnits WITH (NOLOCK) WHERE OrgUnitID = @Expression	
	END 
	-- Chưa chuyển view HCSSYS_VWDepartmentFullInfo do trong view có dùng bảng HCSSYS_VMDepartmentFullLevel chưa chuyển qua Codx
	--ELSE IF @Type = 4
	--BEGIN
	--	SELECT TOP(1) @result = CAP4_Code FROM HCSSYS_VWDepartmentFullInfo WITH (NOLOCK) WHERE DepartmentCode = @Expression
 --   END

	set @result = ISNULL(@result, N'')
	RETURN @result

END


----------------------------10
USE [codx_hr]
GO
/****** Object:  UserDefinedFunction [dbo].[HR_fnFGetHT_LayThongTinBatKyV3]    Script Date: 2/7/2025 6:34:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER FUNCTION [dbo].[HR_fnFGetHT_LayThongTinBatKyV4](
	@EmployeeCode NVARCHAR(20),
	@DowCode VARCHAR(7),
	@ToTime datetime = '2018/12/24',
	@Expression NVARCHAR(200),
	@Type int
)
RETURNS NVARCHAR(200)
AS
BEGIN
	DECLARE @result NVARCHAR(200), @iMonth INT, @iYear INT, @fBegDay DATETIME, @fEndDay DATETIME, @AprRankCode VARCHAR(20)
    
    SET @Expression = LTRIM(RTRIM(@Expression))
	SET @iYear = YEAR(@ToTime)

	IF @Type = 1
	BEGIN
		IF @Expression = 'KQDanhGia_Thang'
		BEGIN
			SET @iMonth = MONTH(@ToTime)

			SELECT TOP(1) @result = AprRankCode
			FROM dbo.HR_AprPeriodic WITH (NOLOCK)
			WHERE EmployeeID = @EmployeeCode AND AprYear = @iYear and AprPeriod = @iMonth
        END
		ELSE IF @Expression = 'KQDanhGia_Nam'
		BEGIN
		
			SELECT TOP(1) @result = AprRankCode
			FROM dbo.HR_AprPeriodic WITH (NOLOCK)
			WHERE EmployeeID = @EmployeeCode AND AprYear = @iYear and AprPeriod = 19
        END
		ELSE IF @Expression = 'KQDanhGia_Quy'
		BEGIN
			SET @iMonth = CASE MONTH(@ToTime) 
				WHEN 1 THEN 13
				WHEN 2 THEN 13
				WHEN 3 THEN 13
				WHEN 4 THEN 14
				WHEN 5 THEN 14
				WHEN 6 THEN 14
				WHEN 7 THEN 15
				WHEN 8 THEN 15
				WHEN 9 THEN 15
				WHEN 10 THEN 16
				WHEN 11 THEN 16
				WHEN 12 THEN 16 END 

			SELECT TOP(1) @result = AprRankCode
			FROM dbo.HR_AprPeriodic WITH (NOLOCK)
			WHERE EmployeeID = @EmployeeCode AND AprYear = @iYear and AprPeriod = @iMonth
        END
		ELSE IF @Expression = 'KQDanhGia_NuaNam'
		BEGIN
			SET @iMonth = CASE MONTH(@ToTime) 
				WHEN 1 THEN 17
				WHEN 2 THEN 17
				WHEN 3 THEN 17
				WHEN 4 THEN 17
				WHEN 5 THEN 17
				WHEN 6 THEN 17
				WHEN 7 THEN 18
				WHEN 8 THEN 18
				WHEN 9 THEN 18
				WHEN 10 THEN 18
				WHEN 11 THEN 18
				WHEN 12 THEN 18 END 

			SELECT TOP(1) @result = AprRankCode
			FROM dbo.HR_AprPeriodic WITH (NOLOCK)
			WHERE EmployeeID = @EmployeeCode AND AprYear = @iYear and AprPeriod = @iMonth
        END
    END
	ELSE IF @Type = 2
	BEGIN
		select top(1) @fBegDay = FromDate, @fEndDay = ToDate from HR_ConfigTSEmpStandardWD where DowCode = @DowCode and EmployeeID = @EmployeeCode

		;with tblAlloGrade as (
			select B.AlloGradeCode, B.IsFixAmount from HR_FNSplitString_varchar(@Expression, '+') as A inner join HR_LSAlloGrade as B on ltrim(rtrim(A.[data])) = B.AlloGradeCode
		)
		select @result = CONVERT(VARCHAR(10), EndDate, 111)
		from (
			select AG.AlloGradeCode as ID, A.EndDate,
				ROW_NUMBER() OVER(PARTITION BY AG.AlloGradeCode ORDER BY EffectDate desc) as Row_ID
			from HR_EmpAllowance as A with (nolock) inner join tblAlloGrade as AG WITH (NOLOCK) on A.AlloGradeCode = AG.AlloGradeCode
			where EmployeeID = @EmployeeCode and 
				(EffectDate <= @fEndDay and (EndDate = '' OR EndDate IS NULL OR EndDate > @fBegDay))
		) as R where Row_ID = 1

		RETURN @result
    END 
	ELSE IF @Type = 3
	BEGIN
		IF NOT EXISTS(SELECT TOP(1) 1 FROM dbo.HR_EmpTracking WITH (NOLOCK)
			WHERE EmployeeID = @EmployeeCode AND TableName = 'HR_Employees' AND FieldName = 'PositionID')
		BEGIN
			SELECT TOP(1) @result = PositionID FROM dbo.HR_Employees WITH (NOLOCK) WHERE EmployeeID = @EmployeeCode	
        END 
		ELSE
        BEGIN
			;WITH tblTmp AS (
				SELECT EffectDate, Value, ValueOld FROM HR_EmpTracking WITH (NOLOCK)
				WHERE EmployeeID = @EmployeeCode AND TableName = 'HR_Employees' AND FieldName = 'PositionID'
			)
			SELECT @result = CASE WHEN EffectDate <= @ToTime THEN Value else ValueOld end
			FROM (
				SELECT EffectDate, Value, ValueOld, ROW_NUMBER() OVER(ORDER BY EffectDate desc) as RowID
				FROM (
					SELECT TOP(1) A.EffectDate, A.Value, A.ValueOld FROM tblTmp AS A ORDER BY EffectDate ASC
					UNION ALL
					SELECT A.EffectDate, A.Value, A.ValueOld FROM tblTmp AS A WHERE A.EffectDate <= @ToTime
				) AS R
			) AS Z WHERE Z.RowID = 1
        END 
    END 
	ELSE IF @Type = 4
	BEGIN
		IF NOT EXISTS(SELECT TOP(1) 1 FROM dbo.HR_EmpTracking WITH (NOLOCK)
			WHERE EmployeeID = @EmployeeCode AND TableName = 'HR_Employees' AND FieldName = 'PositionID')
		BEGIN
			SELECT TOP(1) @result = PositionID FROM dbo.HR_Employees WITH (NOLOCK) WHERE EmployeeID = @EmployeeCode	
        END 
		ELSE
        BEGIN
			;WITH tblTmp AS (
				SELECT EffectDate, Value, ValueOld FROM HR_EmpTracking WITH (NOLOCK)
				WHERE EmployeeID = @EmployeeCode AND TableName = 'HR_Employees' AND FieldName = 'PositionID'
			)
			SELECT @result = CASE WHEN EffectDate <= @ToTime THEN Value else ValueOld end
			FROM (
				SELECT EffectDate, Value, ValueOld, ROW_NUMBER() OVER(ORDER BY EffectDate desc) as RowID
				FROM (
					SELECT TOP(1) A.EffectDate, A.Value, A.ValueOld FROM tblTmp AS A ORDER BY EffectDate ASC
					UNION ALL
					SELECT A.EffectDate, A.Value, A.ValueOld FROM tblTmp AS A WHERE A.EffectDate <= @ToTime
				) AS R
			) AS Z WHERE Z.RowID = 1
        END 

		--SELECT TOP(1) @result = GJWCode FROM dbo.HR_Positions WITH (NOLOCK) WHERE PositionID = @result --Chưa chuyển cấu trúc bảng sang Codx nên chưa có field GJWCode
    END 
	ELSE IF @Type = 5
	BEGIN
		IF NOT EXISTS(SELECT TOP(1) 1 FROM dbo.HR_EmpTracking WITH (NOLOCK)
			WHERE EmployeeID = @EmployeeCode AND TableName = 'HR_Employees' AND FieldName = 'JobLevel')
		BEGIN
			SELECT TOP(1) @result = JobLevel FROM dbo.HR_Employees WITH (NOLOCK) WHERE EmployeeID = @EmployeeCode	
        END 
		ELSE
        BEGIN
			;WITH tblTmp AS (
				SELECT EffectDate, Value, ValueOld FROM HR_EmpTracking WITH (NOLOCK)
				WHERE EmployeeID = @EmployeeCode AND TableName = 'HR_Employees' AND FieldName = 'JobLevel'
			)
			SELECT @result = CASE WHEN EffectDate <= @ToTime THEN Value else ValueOld end
			FROM (
				SELECT EffectDate, Value, ValueOld, ROW_NUMBER() OVER(ORDER BY EffectDate desc) as RowID
				FROM (
					SELECT TOP(1) A.EffectDate, A.Value, A.ValueOld FROM tblTmp AS A ORDER BY EffectDate ASC
					UNION ALL
					SELECT A.EffectDate, A.Value, A.ValueOld FROM tblTmp AS A WHERE A.EffectDate <= @ToTime
				) AS R
			) AS Z WHERE Z.RowID = 1
        END 
    END 
	ELSE IF @Type = 6
	BEGIN
		IF NOT EXISTS(SELECT TOP(1) 1 FROM dbo.HR_EmpTracking WITH (NOLOCK)
			WHERE EmployeeID = @EmployeeCode AND TableName = 'HR_Employees' AND FieldName = 'PositionID')
		BEGIN
			SELECT TOP(1) @result = PositionID FROM dbo.HR_Employees WITH (NOLOCK) WHERE EmployeeID = @EmployeeCode	
        END 
		ELSE
        BEGIN
			;WITH tblTmp AS (
				SELECT EffectDate, Value, ValueOld FROM HR_EmpTracking WITH (NOLOCK)
				WHERE EmployeeID = @EmployeeCode AND TableName = 'HR_Employees' AND FieldName = 'PositionID'
			)
			SELECT @result = CASE WHEN EffectDate <= @ToTime THEN [Value] else ValueOld end
			FROM (
				SELECT EffectDate, Value, ValueOld, ROW_NUMBER() OVER(ORDER BY EffectDate desc) as RowID
				FROM (
					SELECT TOP(1) A.EffectDate, A.Value, A.ValueOld FROM tblTmp AS A ORDER BY EffectDate ASC
					UNION ALL
					SELECT A.EffectDate, A.Value, A.ValueOld FROM tblTmp AS A WHERE A.EffectDate <= @ToTime
				) AS R
			) AS Z WHERE Z.RowID = 1
        END 

		SELECT TOP(1) @result = PositionName2 FROM dbo.HR_Positions WITH (NOLOCK) WHERE PositionID = @result
    END 
	ELSE IF @Type = 7
	BEGIN
		IF NOT EXISTS(SELECT TOP(1) 1 FROM dbo.HR_EmpTracking WITH (NOLOCK)
			WHERE EmployeeID = @EmployeeCode AND TableName = 'HR_Employees' AND FieldName = 'PositionID')
		BEGIN
			SELECT TOP(1) @result = PositionID FROM dbo.HR_Employees WITH (NOLOCK) WHERE EmployeeID = @EmployeeCode	
        END 
		ELSE
        BEGIN
			;WITH tblTmp AS (
				SELECT EffectDate, Value, ValueOld FROM HR_EmpTracking WITH (NOLOCK)
				WHERE EmployeeID = @EmployeeCode AND TableName = 'HR_Employees' AND FieldName = 'PositionID'
			)
			SELECT @result = CASE WHEN EffectDate <= @ToTime THEN Value else ValueOld end
			FROM (
				SELECT EffectDate, Value, ValueOld, ROW_NUMBER() OVER(ORDER BY EffectDate desc) as RowID
				FROM (
					SELECT TOP(1) A.EffectDate, A.Value, A.ValueOld FROM tblTmp AS A ORDER BY EffectDate ASC
					UNION ALL
					SELECT A.EffectDate, A.Value, A.ValueOld FROM tblTmp AS A WHERE A.EffectDate <= @ToTime
				) AS R
			) AS Z WHERE Z.RowID = 1
        END 
		--Chưa chuyển field GJWCode và bảng HR_PositionsGroup
		--SELECT TOP(1) @result = GJWCode FROM dbo.HR_Positions WITH (NOLOCK) WHERE PositionID = @result
		--SELECT TOP(1) @result = GJWName2 FROM dbo.HR_PositionsGroup WITH (NOLOCK) WHERE GjwCode = @result
    END 
	ELSE IF @Type = 8
	BEGIN
		IF NOT EXISTS(SELECT TOP(1) 1 FROM dbo.HR_EmpTracking WITH (NOLOCK)
			WHERE EmployeeID = @EmployeeCode AND TableName = 'HR_Employees' AND FieldName = 'JobLevel')
		BEGIN
			SELECT TOP(1) @result = JobLevel FROM dbo.HR_Employees WITH (NOLOCK) WHERE EmployeeID = @EmployeeCode	
        END 
		ELSE
        BEGIN
			;WITH tblTmp AS (
				SELECT EffectDate, Value, ValueOld FROM HR_EmpTracking WITH (NOLOCK)
				WHERE EmployeeID = @EmployeeCode AND TableName = 'HR_Employees' AND FieldName = 'JobLevel'
			)
			SELECT @result = CASE WHEN EffectDate <= @ToTime THEN Value else ValueOld end
			FROM (
				SELECT EffectDate, Value, ValueOld, ROW_NUMBER() OVER(ORDER BY EffectDate desc) as RowID
				FROM (
					SELECT TOP(1) A.EffectDate, A.Value, A.ValueOld FROM tblTmp AS A ORDER BY EffectDate ASC
					UNION ALL
					SELECT A.EffectDate, A.Value, A.ValueOld FROM tblTmp AS A WHERE A.EffectDate <= @ToTime
				) AS R
			) AS Z WHERE Z.RowID = 1
        END 

		SELECT TOP(1) @result = Description FROM dbo.HR_JobLevels WITH (NOLOCK) WHERE JobLevel = @result
    END 
	

	set @result = ISNULL(@result, N'')
	RETURN @result

END


-------------------------12

USE [codx_hr]
GO
/****** Object:  UserDefinedFunction [dbo].[HR_fnFGetHT_LayThongTinBatKyV6]    Script Date: 2/7/2025 6:34:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER FUNCTION [dbo].[HR_fnFGetHT_LayThongTinBatKyV6](
	@EmployeeCode NVARCHAR(20) = 'ELV01016',
	@DowCode VARCHAR(7) = '2019/01',
	@GroupSalCode varchar(20) = 'aa',
	@ToTime datetime = '2018/12/24',
	@Exp1 varchar(max) = 'AG_KPI+AG_TN+AG_CVU+AG_TNIEN+AG_KN',
	@Exp2 varchar(max) = 'AG_KPI+AG_TN+AG_CVU+AG_TNIEN+AG_KN',
	@Exp3 varchar(max) = 'AG_KPI+AG_TN+AG_CVU+AG_TNIEN+AG_KN',
	@Type int = 16
)
RETURNS float
AS
BEGIN
	declare @result float, @fBegDay datetime, @fEndDay DATETIME
	declare @ConTypeCode VARCHAR(20), @GroupRider VARCHAR(20), @HotzoneCode VARCHAR(20), @AlloGradeCode VARCHAR(20), @DonGiaZone FLOAT
	DECLARE @MinQuantity INT, @Amount FLOAT, @SoKienHang FLOAT, @NgayCongThucTe FLOAT, @StandardWD FLOAt, @AVG FLOAT , @TileThanhCong FLOAT
	DECLARE @tmpString varchar(20), @tmpValue float, @tmpDayNum float

	SET @Exp1 = LTRIM(RTRIM(@Exp1))
	SET @Exp2 = LTRIM(RTRIM(@Exp2))
	SET @Exp3 = LTRIM(RTRIM(@Exp3))

	-- HCSLS_BonusDelivery_NJV
	IF @Type = 1
	BEGIN		
		
		SELECT top(1) @fBegDay = FromDate, @fEndDay = ToDate, @DowCode = DowCode from HR_ConfigTSEmpStandardWD WITH (NOLOCK) WHERE ToDate <= @ToTime and EmployeeID = @EmployeeCode order by FromDate DESC

		SELECT TOP(1) @GroupRider = B.GroupRider
		FROM dbo.HR_EmployeeExt AS A WITH (NOLOCK) INNER JOIN dbo.HR_LSRegion AS B WITH (NOLOCK) ON A.AssignRegionCode = B.RegionCode
		WHERE EmployeeID = @EmployeeCode

		-- Lấy hợp đồng mới nhất còn hiệu lực.
		select @ConTypeCode = R.ConTypeCode
		from (
			select A.ConTypeCode, ROW_NUMBER() OVER(ORDER BY A.ContFrom desc) as Row_ID, A.ContTo
			from dbo.HR_EmpContract as A with (nolock)
			where EmployeeID = @EmployeeCode and A.ContFrom <= @fEndDay
		) as R where Row_ID = 1 AND (R.ContTo IS NULL OR R.ContTo >= @fBegDay)

		-- số kiện hàng mức đó (lấy trong heso luong thuong)) = ST1 trong SalCoeffEmp
		set @SoKienHang = 0
		;WITH tblA AS (
			SELECT LTRIM(RTRIM(data)) AS Code FROM dbo.HR_FNSplitString_varchar(@Exp1, ',')
		)
		SELECT @SoKienHang = ISNULL(SUM(T.Coefficient), 0)
		FROM dbo.HR_PRSalCoeffEmp AS T WITH (NOLOCK) INNER JOIN tblA AS T1 ON T.CoeffCode = T1.Code
		WHERE T.EmployeeID = @EmployeeCode AND T.DowCode = @DowCode


		set @NgayCongThucTe = 0
		;WITH tblA AS (
			SELECT LTRIM(RTRIM(data)) AS Code FROM dbo.HR_FNSplitString_varchar(@Exp3, ',')
		)
		SELECT @NgayCongThucTe = ISNULL(SUM(T.DayNum), 0)
		FROM dbo.HR_TSKowDs AS T WITH (NOLOCK) INNER JOIN tblA AS T1 ON T.KowCode = T1.Code
		WHERE T.EmployeeID = @EmployeeCode AND T.DowCode = @DowCode

		-- Từ nhân viên => hợp đồng và group óps để xác định số tiền và Thamso1  số kiện hàng tối thiểu.
		-- Từ nhân viên => hợp đồng và group óps để xác định số tiền và Thamso1  đơn giá zone nào (mức nào) theo ops = SoTien

		-- Chưa chuyển bảng HCSLS_BonusDelivery_NJV
		--set @MinQuantity = 0
		--set @Amount = 0
		--SELECT TOP(1) @MinQuantity = MinQuantity, @Amount = T.Amount
		--FROM (
		--	SELECT T.MinQuantity, T.Amount, 
		--		DENSE_RANK() OVER (PARTITION BY T.GroupCode ORDER BY GroupCode, T.EffectDate desc) AS Row_ID
		--	FROM HCSLS_BonusDelivery_NJV AS T WITH (NOLOCK)
		--	WHERE T.GroupCode = @GroupRider AND T.ConTypeCode = @ConTypeCode AND T.CoeffCode = @Exp1
		--		and T.GroupSalCode = @GroupSalCode
		--		AND T.EffectDate <= @fEndDay
		--) AS T WHERE T.Row_ID = 1

		--set @DonGiaZone = 0
		---- đơn giá zone 1 theo ops = ST2 
		--SELECT TOP(1) @DonGiaZone = T.Amount
		--FROM (
		--	SELECT T.MinQuantity, T.Amount, 
		--		DENSE_RANK() OVER (PARTITION BY T.GroupCode ORDER BY GroupCode, T.EffectDate desc) AS Row_ID
		--	FROM HCSLS_BonusDelivery_NJV AS T WITH (NOLOCK)
		--	WHERE T.GroupCode = @GroupRider AND T.ConTypeCode = @ConTypeCode AND T.CoeffCode = @Exp2 
		--		and T.GroupSalCode = @GroupSalCode
		--		AND T.EffectDate <= @fEndDay
		--) AS T WHERE T.Row_ID = 1
		
		--if @Amount * @SoKienHang < ISNULL(@MinQuantity * @NgayCongThucTe * @DonGiaZone,0)
		--	set @result = 0
		--else
		SET @result = @Amount * @SoKienHang - ISNULL(@MinQuantity * @NgayCongThucTe * @DonGiaZone,0)
	END
	-- HCSLS_BonusPerformancebyRate_NJV
	ELSE IF @Type = 2
	BEGIN
		SELECT top(1) @fBegDay = FromDate, @fEndDay = ToDate, @DowCode = DowCode from HR_ConfigTSEmpStandardWD WITH (NOLOCK) WHERE ToDate <= @ToTime and EmployeeID = @EmployeeCode order by FromDate DESC

		SELECT TOP(1) @tmpString = B.GroupRider
		FROM dbo.HR_EmployeeExt AS A WITH (NOLOCK) INNER JOIN dbo.HR_LSRegion AS B WITH (NOLOCK) ON A.AssignRegionCode = B.RegionCode
		WHERE EmployeeID = @EmployeeCode

		-- Value 1. Tỷ lệ thành công
		;WITH tblA AS (
			SELECT LTRIM(RTRIM(data)) AS Code FROM dbo.HR_FNSplitString_varchar(@Exp1, ',')
		)
		SELECT @TileThanhCong = ISNULL(SUM(T.Coefficient), 0)
		FROM dbo.HR_PRSalCoeffEmp AS T WITH (NOLOCK) INNER JOIN tblA AS T1 ON T.CoeffCode = T1.Code
		WHERE T.EmployeeID = @EmployeeCode AND T.DowCode = @DowCode

		-- Value 2. AVG: Trung binh kien hang
		;WITH tblA AS (
			SELECT LTRIM(RTRIM(data)) AS Code FROM dbo.HR_FNSplitString_varchar(@Exp2, ',')
		)
		SELECT @AVG = ISNULL(SUM(T.Coefficient), 0)
		FROM dbo.HR_PRSalCoeffEmp AS T WITH (NOLOCK) INNER JOIN tblA AS T1 ON T.CoeffCode = T1.Code
		WHERE T.EmployeeID = @EmployeeCode AND T.DowCode = @DowCode


		-- Số kiện hàng tối thiểu
		-- Chưa chuyển HCSLS_BonusPerformancebyRate_MinQuantity_NJV
		--SELECT TOP(1) @tmpValue = MinQuantity
		--FROM HCSLS_BonusPerformancebyRate_MinQuantity_NJV WITH (NOLOCK) 
		--WHERE GroupCode = @tmpString AND EffectDate <= @fEndDay
		--	and GroupSalCode = @GroupSalCode
		--ORDER BY EffectDate DESC
        
		SET @AVG = ISNULL(@AVG, 0)
		SET @tmpValue = ISNULL(@tmpValue, 0)
		SET @TileThanhCong = ISNULL(@TileThanhCong, 0)

		IF @AVG < @tmpValue
		BEGIN
			SET @result = 0
        END
		-- Chưa chuyển HCSLS_BonusPerformancebyRate_NJV
  --      ELSE
  --      begin
		--	SELECT @result = T.Amount
		--	FROM (
		--		SELECT T.Amount, T.FromNum, T.ToNum, 
		--			DENSE_RANK() OVER (PARTITION BY T.EffectDate ORDER BY T.EffectDate desc) AS Row_ID
		--		FROM HCSLS_BonusPerformancebyRate_NJV AS T WITH (NOLOCK)
		--		WHERE T.EffectDate <= @fEndDay and GroupSalCode = @GroupSalCode
		--	) AS T WHERE T.Row_ID = 1 AND @TileThanhCong >= FromNum AND @TileThanhCong < ToNum
		--END 
	END
	-- HCSLS_Hotzone_Allowance
	ELSE IF @Type = 3
	BEGIN

		SELECT top(1) @fBegDay = FromDate, @fEndDay = ToDate, @DowCode = DowCode, @StandardWD = StandardWD from HR_ConfigTSEmpStandardWD WITH (NOLOCK) WHERE ToDate <= @ToTime and EmployeeID = @EmployeeCode order by FromDate DESC

		SELECT TOP(1) @tmpString = A.AssignRegionCode FROM dbo.HR_EmployeeExt AS A WITH (NOLOCK) WHERE EmployeeID = @EmployeeCode

		SELECT TOP(1) @HotzoneCode = HotzoneCode FROM dbo.HR_LSRegion WITH (NOLOCK) WHERE RegionCode = @tmpString

		-- Chưa chuyển HCSLS_Hotzone_Allowance
		--SELECT @tmpValue = R.Amount
		--FROM (
		--	SELECT TOP(1) FromDate, ToDate, Amount
		--	FROM HCSLS_Hotzone_Allowance WITH (NOLOCK) 
		--	WHERE HotzoneCode = @HotzoneCode AND AlloGradeCode = @Exp1 and FromDate <= @fEndDay
		--) AS R WHERE R.ToDate IS NULL OR R.ToDate >= @fBegDay

		IF ISNULL(@tmpValue,0) <= 0
		BEGIN
		-- Chưa chuyển HR_LSRegion_Allowance
			--SELECT @tmpValue = R.Amount
			--FROM (
			--	SELECT TOP(1) FromDate, ToDate, Amount
			--	FROM dbo.HR_LSRegion_Allowance WITH (NOLOCK) 
			--	WHERE RegionCode = @tmpString AND AlloGradeCode = @Exp1 and FromDate <= @fEndDay
			--) AS R WHERE R.ToDate IS NULL OR R.ToDate >= @fBegDay

			SET @tmpValue = ISNULL(@tmpValue, 0)

			-- Value 1. Tỷ lệ thành công
			;WITH tblA AS (
				SELECT LTRIM(RTRIM(data)) AS Code FROM dbo.HR_FNSplitString_varchar(@Exp2, ',')
			)
			SELECT @result = @tmpValue * ISNULL(SUM(T.DayNum), 0)
			FROM dbo.HR_TSKowDs AS T WITH (NOLOCK) INNER JOIN tblA AS T1 ON T.KowCode = T1.Code
			WHERE T.EmployeeID = @EmployeeCode AND T.DowCode = @DowCode
        END
		ELSE
		BEGIN
			-- Value 1. Tỷ lệ thành công
			;WITH tblA AS (
				SELECT LTRIM(RTRIM(data)) AS Code FROM dbo.HR_FNSplitString_varchar(@Exp2, ',')
			)
			SELECT @result = @tmpValue / @StandardWD * ISNULL(SUM(T.DayNum), 0)
			FROM dbo.HR_TSKowDs AS T WITH (NOLOCK) INNER JOIN tblA AS T1 ON T.KowCode = T1.Code
			WHERE T.EmployeeID = @EmployeeCode AND T.DowCode = @DowCode
        END 
       
		
	END
	-- HCSLS_SalarybyContractType_NJV
	IF @Type = 4
	BEGIN
		select top(1) @fBegDay = FromDate, @fEndDay = ToDate, @DowCode = DowCode from HR_ConfigTSEmpStandardWD WITH (NOLOCK) WHERE ToDate <= @ToTime and EmployeeID = @EmployeeCode order by FromDate DESC

		-- Lấy hợp đồng mới nhất còn hiệu lực.
		select @tmpString = R.ConTypeCode
		from (
			select A.ConTypeCode, ROW_NUMBER() OVER(ORDER BY A.ContFrom desc) as Row_ID, A.ContTo
			from dbo.HR_EmpContract as A with (nolock)
			where EmployeeID = @EmployeeCode and A.ContFrom <= @fEndDay
		) as R where Row_ID = 1 AND (R.ContTo IS NULL OR R.ContTo >= @fBegDay)

		SELECT TOP(1) @GroupRider = B.GroupRider
		FROM dbo.HR_EmployeeExt AS A WITH (NOLOCK) INNER JOIN dbo.HR_LSRegion AS B WITH (NOLOCK) ON A.AssignRegionCode = B.RegionCode
		WHERE EmployeeID = @EmployeeCode

		-- he so
		;WITH tblA AS (
			SELECT CAST(LTRIM(RTRIM(data)) AS VARCHAR(20)) AS Code FROM dbo.HR_FNSplitString_varchar(@Exp1, '+')
		)
		SELECT @tmpDayNum = ISNULL(SUM(T.Coefficient), 0)
		FROM dbo.HR_PRSalCoeffEmp AS T WITH (NOLOCK) INNER JOIN tblA AS T1 ON T.CoeffCode = T1.Code
		WHERE T.EmployeeID = @EmployeeCode AND T.DowCode = @DowCode

		-- Chưa chuyển HCSLS_SalarybyContractType_NJV
		--SELECT @result = SUM(Amount)
		--FROM HCSLS_SalarybyContractType_NJV WITH (NOLOCK) 
		--WHERE ConTypeCode = @tmpString AND @tmpDayNum >= FromNum AND @tmpDayNum <= ToNum and GroupCode = @GroupRider
		--	and GroupSalCode = @GroupSalCode
	END
	ELSE IF @Type = 5
	BEGIN

		SELECT top(1) @fBegDay = FromDate, @fEndDay = ToDate, @DowCode = DowCode from HR_ConfigTSEmpStandardWD WITH (NOLOCK) WHERE ToDate <= @ToTime and EmployeeID = @EmployeeCode order by FromDate DESC

		SELECT TOP(1) @tmpString = B.GroupRider
		FROM dbo.HR_EmployeeExt AS A WITH (NOLOCK) INNER JOIN dbo.HR_LSRegion AS B WITH (NOLOCK) ON A.AssignRegionCode = B.RegionCode
		WHERE EmployeeID = @EmployeeCode

		;WITH tblA AS (
			SELECT LTRIM(RTRIM(data)) AS Code FROM dbo.HR_FNSplitString_varchar(@Exp1, '+')
		)
		SELECT @tmpDayNum = ISNULL(SUM(T.Coefficient), 0)
		FROM dbo.HR_PRSalCoeffEmp AS T WITH (NOLOCK) INNER JOIN tblA AS T1 ON T.CoeffCode = T1.Code
		WHERE T.EmployeeID = @EmployeeCode AND T.DowCode = @DowCode

		--SELECT @result = SUM((T.ToNum - T.FromNum) * T.Amount)
		--FROM (
		--	SELECT T.Amount, T.FromNum, CASE WHEN @tmpDayNum < T.ToNum THEN @tmpDayNum ELSE T.ToNum END AS ToNum, 
		--		DENSE_RANK() OVER (PARTITION BY T.GroupCode ORDER BY GroupCode, T.EffectDate desc) AS Row_ID
		--	FROM HCSLS_BonusPerformancebyQuantity_NJV AS T WITH (NOLOCK)
		--	WHERE T.GroupCode = @tmpString AND T.EffectDate <= @fEndDay
		--) AS T WHERE T.Row_ID = 1 AND T.FromNum <= @tmpDayNum
	END
	-- HCSLS_BonusPickup_NJV
	ELSE IF @Type = 6
	BEGIN
		select top(1) @fBegDay = FromDate, @fEndDay = ToDate, @DowCode = DowCode from HR_ConfigTSEmpStandardWD WITH (NOLOCK) WHERE ToDate <= @ToTime and EmployeeID = @EmployeeCode order by FromDate DESC

		SELECT TOP(1) @GroupRider = B.GroupRider
		FROM dbo.HR_EmployeeExt AS A WITH (NOLOCK) INNER JOIN dbo.HR_LSRegion AS B WITH (NOLOCK) ON A.AssignRegionCode = B.RegionCode
		WHERE EmployeeID = @EmployeeCode

		-- Lấy hợp đồng mới nhất còn hiệu lực.
		select @tmpString = R.ConTypeCode
		from (
			select A.ConTypeCode, ROW_NUMBER() OVER(ORDER BY A.ContFrom desc) as Row_ID, A.ContTo
			from dbo.HR_EmpContract as A with (nolock)
			where EmployeeID = @EmployeeCode and A.ContFrom <= @fEndDay
		) as R where Row_ID = 1 AND (R.ContTo IS NULL OR R.ContTo >= @fBegDay)

		-- he so
		;WITH tblA AS (
			SELECT CAST(LTRIM(RTRIM(data)) AS VARCHAR(20)) AS Code FROM dbo.HR_FNSplitString_varchar(@Exp1, '+')
		)
		SELECT @tmpDayNum = ISNULL(SUM(T.Coefficient), 0)
		FROM dbo.HR_PRSalCoeffEmp AS T WITH (NOLOCK) INNER JOIN tblA AS T1 ON T.CoeffCode = T1.Code
		WHERE T.EmployeeID = @EmployeeCode AND T.DowCode = @DowCode

		-- Chưa chuyển HCSLS_BonusPickup_NJV
		--SELECT @result = SUM(Amount) * @tmpDayNum
		--FROM HCSLS_BonusPickup_NJV WITH (NOLOCK) 
		--WHERE GroupCode = @GroupRider AND CoeffCode = @Exp1 and ConTypeCode = @tmpString 
		--and GroupSalCode = @GroupSalCode
	END	

	SET @result = ISNULL(@result, 0)
	return @result

END


--------------
HT_LayThongTinBatKy
HT_LayThongTinBatKyTheoBP
HT_LayThongTinBatKyTheoBPV2
HT_LayThongTinBatKyV2
HT_LayThongTinBatKyV3
HT_LayThongTinBatKyV4
HT_LayThongTinBatKyV5
HT_LayThongTinBatKyV6
HT_LayThongTinLuongBatKy
HT_LayThongTinLuongBatKyV2
HT_LayThongTinLuongBatKyV3