

/****** Object:  Table [dbo].[Measurement]    Script Date: 7/18/2023 10:17:36 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Measurement](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[BeerId] [int] NOT NULL,
	[TimeStamp] [datetime] NOT NULL,
	[SpecificGravity] [decimal](18, 5) NOT NULL,
	[TemperatureFahrenheit] [decimal](18, 5) NOT NULL,
	[Comment] [nvarchar](max) NULL,
	[TiltColor] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_Measurement] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[Measurement]  WITH CHECK ADD  CONSTRAINT [FK_Measurement_Beer] FOREIGN KEY([BeerId])
REFERENCES [dbo].[Beer] ([Id])
GO

ALTER TABLE [dbo].[Measurement] CHECK CONSTRAINT [FK_Measurement_Beer]
GO


