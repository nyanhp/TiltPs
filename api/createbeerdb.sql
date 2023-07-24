/****** Object:  Table [dbo].[Beer]    Script Date: 7/18/2023 10:18:08 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Beer]') AND type in (N'U'))
DROP TABLE [dbo].[Beer]
GO

/****** Object:  Table [dbo].[Beer]    Script Date: 7/18/2023 10:18:08 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Beer](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](150) NOT NULL,
	[Style] [nvarchar](50) NOT NULL,
	[Brewed] [datetime] NULL,
	[Bottled] [datetime] NULL,
	[TotalBottles] [smallint] NULL,
	[RemainingBottles] [smallint] NULL,
	[BatchSizeLitres] [smallint] NULL,
	[BitternessUnits] [smallint] NULL,
	[Color] [smallint] NULL,
	[OriginalGravity] [decimal](18, 5) NULL,
	[FinalGravity] [decimal](18, 5) NULL,
 CONSTRAINT [PK_Beer] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


