# 1、PDFSharp

> [微软雅黑字体](simfang.ttf)

```c#
//构建PDF文档
using (PdfSharp.Pdf.PdfDocument pdfDocument = new PdfSharp.Pdf.PdfDocument())
{
	int pagecount=0;
	int fristCount=Index.Length>=18?18:Index.Length;
	//添加页面
	PdfSharp.Pdf.PdfPage page = pdfDocument.AddPage();
	//获取绘制对象
	PdfSharp.Drawing.XGraphics gfx = PdfSharp.Drawing.XGraphics.FromPdfPage(page);
	//文本布局对象
	//PdfSharp.Drawing.Layout.XTextFormatter tf = new PdfSharp.Drawing.Layout.XTextFormatter(gfx);
	
	//绘制画笔
	PdfSharp.Drawing.XPen pen= new PdfSharp.Drawing.XPen(PdfSharp.Drawing.XColors.Black, 0.6);
	//边距
	int marginLeft = 30;
    int marginTop = 20;
	
	//画个框
	PdfSharp.Drawing.XRect rect = new PdfSharp.Drawing.XRect(marginLeft, marginTop, page.Width - 2 * marginLeft, page.Height - 2 * marginTop);
	//标题
    //支持中文
	System.Drawing.Text.PrivateFontCollection pfcFonts = new System.Drawing.Text.PrivateFontCollection();
    string strFontPath = @"D:/install/Fonts/simfang.ttf";//字体设置为微软雅黑
    pfcFonts.AddFontFile(strFontPath);
	PdfSharp.Drawing.XPdfFontOptions options = new PdfSharp.Drawing.XPdfFontOptions(PdfSharp.Pdf.PdfFontEncoding.Unicode,PdfSharp.Pdf.PdfFontEmbedding.Always);
	//字体
	PdfSharp.Drawing.XFont font = new PdfSharp.Drawing.XFont(pfcFonts.Families[0],20,PdfSharp.Drawing.XFontStyle.Regular, options);
	PdfSharp.Drawing.XFont subfont = new PdfSharp.Drawing.XFont(pfcFonts.Families[0], 12, PdfSharp.Drawing.XFontStyle.Regular, options);
	//粗体
	PdfSharp.Drawing.XFont boldfont = new PdfSharp.Drawing.XFont(pfcFonts.Families[0], 10, PdfSharp.Drawing.XFontStyle.Bold, options);
	//小一点的字体
	PdfSharp.Drawing.XFont smallfont = new PdfSharp.Drawing.XFont(pfcFonts.Families[0], 8, PdfSharp.Drawing.XFontStyle.Regular, options);
	//Inflate(double width,double height);  
	//width是水平方向的，height是垂直方向的，当width和height的值为正数时是冷缩，为负数是膨胀。
	rect.Inflate(0, -10);
	
	gfx.DrawString("生产入库单", font, PdfSharp.Drawing.XBrushes.Red, rect, PdfSharp.Drawing.XStringFormats.TopCenter);
	
	//间距
	int padding_title = 30;
	int padding_row = 20;
	
	//所属工厂 rect位置
    rect.Location = new PdfSharp.Drawing.XPoint(marginLeft, marginTop + padding_title + padding_row);
	
	gfx.DrawString("所属工厂："+Facility, subfont, PdfSharp.Drawing.XBrushes.Black, rect, PdfSharp.Drawing.XStringFormats.TopLeft);
	
	//第二行
	//入库单号 rect位置
    rect.Location = new PdfSharp.Drawing.XPoint(marginLeft, marginTop + padding_title + padding_row * 2);
	gfx.DrawString("入库单号："+OrderNo, subfont, PdfSharp.Drawing.XBrushes.Black, rect, PdfSharp.Drawing.XStringFormats.TopLeft);
	
	//料框编码 rect位置
    rect.Location = new PdfSharp.Drawing.XPoint(marginLeft + 180, marginTop + padding_title + padding_row * 2);
	gfx.DrawString("料框编码："+Container, subfont, PdfSharp.Drawing.XBrushes.Black, rect, PdfSharp.Drawing.XStringFormats.TopLeft);
	
	//入库仓库 rect位置
    rect.Location = new PdfSharp.Drawing.XPoint(marginLeft + 315, marginTop + padding_title + padding_row * 2);
	gfx.DrawString("入库仓库："+Warehouse, subfont, PdfSharp.Drawing.XBrushes.Black, rect, PdfSharp.Drawing.XStringFormats.TopLeft);
	
	//第三行
	//请求料点 rect位置
    rect.Location = new PdfSharp.Drawing.XPoint(marginLeft, marginTop + padding_title + padding_row * 3);
	gfx.DrawString("请求料点："+FromLocation, subfont, PdfSharp.Drawing.XBrushes.Black, rect, PdfSharp.Drawing.XStringFormats.TopLeft);
	
	//创建日期 rect位置
    rect.Location = new PdfSharp.Drawing.XPoint(marginLeft + 180, marginTop + padding_title + padding_row * 3);
	gfx.DrawString("创建日期："+CreateDate, subfont, PdfSharp.Drawing.XBrushes.Black, rect, PdfSharp.Drawing.XStringFormats.TopLeft);
	
	//创建用户 rect位置
    //rect.Location = new PdfSharp.Drawing.XPoint(marginLeft + 315, marginTop + padding_title + padding_row * 3);
	//gfx.DrawString("创建用户："+CreateUser, subfont, PdfSharp.Drawing.XBrushes.Black, rect, PdfSharp.Drawing.XStringFormats.TopLeft);
	
	//构造二维码
    #region QRCode
    var qrCodeMS = new System.IO.MemoryStream();
    ZXing.BarcodeWriter qrcodeWriter = new ZXing.BarcodeWriter();
    qrcodeWriter.Format = ZXing.BarcodeFormat.QR_CODE;//二维码format
	
	//入库单
	string st5 = OrderNo;
	if(!string.IsNullOrEmpty(st5))
	{				
	    qrcodeWriter.Write(OrderNo).Save(qrCodeMS, System.Drawing.Imaging.ImageFormat.Png);

	    PdfSharp.Drawing.XImage qrcodeImg = PdfSharp.Drawing.XImage.FromStream(qrCodeMS);
	    gfx.DrawImage(qrcodeImg, 450, 20, 140, 140);
	}
    #endregion
	
	//画表格  rect位置
    rect.Location = new PdfSharp.Drawing.XPoint(marginLeft, marginTop + 115);
	//表格高度
	double title_height = 20;
	double row_height = 30;
	
	//根据内容画表
	double table_height = title_height + fristCount * row_height;
	//表格方框
	PdfSharp.Drawing.XRect table_rect = new PdfSharp.Drawing.XRect(rect.X,rect.Y,rect.Width,table_height);
	gfx.DrawRectangle(pen, table_rect);
	
	//分成28份，权重-每一列的宽度
	double col_index = (table_rect.Width/28) * 2;
	double col_wiporderno = (table_rect.Width/28) * 4;
	double col_productno = (table_rect.Width/28) * 4;
	double col_productdesc = (table_rect.Width/28) * 8;
	double col_productalias = (table_rect.Width/28) * 4;
	double col_quantity = (table_rect.Width/28) * 2;
	double col_serialno = (table_rect.Width/28) * 4;
	
	//标题方框
    var countX = table_rect.X;
	
	PdfSharp.Drawing.XRect rect_title_index = new PdfSharp.Drawing.XRect(table_rect.X, 
		table_rect.Y, col_index, title_height);
	PdfSharp.Drawing.XRect rect_title_wiporderno = new PdfSharp.Drawing.XRect(table_rect.X + col_index, 
		table_rect.Y, col_wiporderno, title_height);
	PdfSharp.Drawing.XRect rect_title_productno = new PdfSharp.Drawing.XRect(table_rect.X + col_index + col_wiporderno, 
		table_rect.Y, col_productno, title_height);
	PdfSharp.Drawing.XRect rect_title_productdesc = new PdfSharp.Drawing.XRect(table_rect.X + col_index + col_wiporderno + col_productno, 
		table_rect.Y, col_productdesc, title_height);
	PdfSharp.Drawing.XRect rect_title_productalias = new PdfSharp.Drawing.XRect(table_rect.X + col_index + col_wiporderno + col_productno + col_productdesc , 
		table_rect.Y, col_productalias, title_height);
	PdfSharp.Drawing.XRect rect_title_quantity = new PdfSharp.Drawing.XRect(table_rect.X + col_index + col_wiporderno + col_productno + col_productdesc + col_productalias, 
		table_rect.Y, col_quantity, title_height);
	PdfSharp.Drawing.XRect rect_title_serialno = new PdfSharp.Drawing.XRect(table_rect.X + col_index + col_wiporderno + col_productno + col_productdesc + col_productalias + col_quantity, 
		table_rect.Y, col_serialno, title_height);
	//画格子边框
	gfx.DrawRectangle(pen, rect_title_index);
	gfx.DrawRectangle(pen, rect_title_wiporderno);
	gfx.DrawRectangle(pen, rect_title_productno);
	gfx.DrawRectangle(pen, rect_title_productdesc);
	gfx.DrawRectangle(pen, rect_title_productalias);
	gfx.DrawRectangle(pen, rect_title_quantity);
	gfx.DrawRectangle(pen, rect_title_serialno);
	//标题
	gfx.DrawString("序号", boldfont, PdfSharp.Drawing.XBrushes.Black, rect_title_index, PdfSharp.Drawing.XStringFormats.Center);
	gfx.DrawString("生产工单", boldfont, PdfSharp.Drawing.XBrushes.Black, rect_title_wiporderno, PdfSharp.Drawing.XStringFormats.Center);
	gfx.DrawString("物料编码", boldfont, PdfSharp.Drawing.XBrushes.Black, rect_title_productno, PdfSharp.Drawing.XStringFormats.Center);
	gfx.DrawString("物料描述", boldfont, PdfSharp.Drawing.XBrushes.Black, rect_title_productdesc, PdfSharp.Drawing.XStringFormats.Center);
	gfx.DrawString("物料简码", boldfont, PdfSharp.Drawing.XBrushes.Black, rect_title_productalias, PdfSharp.Drawing.XStringFormats.Center);
	gfx.DrawString("数量", boldfont, PdfSharp.Drawing.XBrushes.Black, rect_title_quantity, PdfSharp.Drawing.XStringFormats.Center);
	gfx.DrawString("序列号", boldfont, PdfSharp.Drawing.XBrushes.Black, rect_title_serialno, PdfSharp.Drawing.XStringFormats.Center);
	//内容方框
	PdfSharp.Drawing.XRect rect_col_index,rect_col_wiporderno,rect_col_productno,rect_col_productdesc, rect_col_productalias, rect_col_quantity,rect_col_serialno;
	
	for(int i=0;i<fristCount;i++)
	{	
		double Height_Y = row_height * i;
		//格子位置
		rect_col_index = new PdfSharp.Drawing.XRect(table_rect.X, 
		table_rect.Y + title_height + Height_Y, col_index, row_height);
		rect_col_wiporderno = new PdfSharp.Drawing.XRect(table_rect.X + col_index, 
		table_rect.Y + title_height + Height_Y, col_wiporderno, row_height);
		rect_col_productno = new PdfSharp.Drawing.XRect(table_rect.X + col_index + col_wiporderno, 
		table_rect.Y + title_height + Height_Y, col_productno, row_height);
		rect_col_productdesc = new PdfSharp.Drawing.XRect(table_rect.X + col_index + col_wiporderno + col_productno, 
		table_rect.Y + title_height + Height_Y, col_productdesc, row_height);
		rect_col_productalias = new PdfSharp.Drawing.XRect(table_rect.X + col_index + col_wiporderno + col_productno  + col_productdesc, 
		table_rect.Y + title_height + Height_Y, col_productalias, row_height);
		rect_col_quantity = new PdfSharp.Drawing.XRect(table_rect.X + col_index + col_wiporderno + col_productno + col_productdesc + col_productalias, 
		table_rect.Y + title_height + Height_Y, col_quantity, row_height);
		rect_col_serialno = new PdfSharp.Drawing.XRect(table_rect.X + col_index + col_wiporderno + col_productno + col_productdesc  + col_productalias + col_quantity, 
		table_rect.Y + title_height + Height_Y, col_serialno, row_height);
		//画格子边框
		gfx.DrawRectangle(pen, rect_col_index);
		gfx.DrawRectangle(pen, rect_col_wiporderno);
		gfx.DrawRectangle(pen, rect_col_productno);
		gfx.DrawRectangle(pen, rect_col_productdesc);
		gfx.DrawRectangle(pen, rect_col_productalias);
		gfx.DrawRectangle(pen, rect_col_quantity);
		gfx.DrawRectangle(pen, rect_col_serialno);
		//填充每一列的内容
		gfx.DrawString(Index[i].ToString("F0"), smallfont, PdfSharp.Drawing.XBrushes.Black, rect_col_index, PdfSharp.Drawing.XStringFormats.Center);
		gfx.DrawString(WipOrderNo[i], smallfont, PdfSharp.Drawing.XBrushes.Black, rect_col_wiporderno, PdfSharp.Drawing.XStringFormats.Center);
		gfx.DrawString(ProductNo[i], smallfont, PdfSharp.Drawing.XBrushes.Black, rect_col_productno, PdfSharp.Drawing.XStringFormats.Center);
		gfx.DrawString(ProductDesc[i], smallfont, PdfSharp.Drawing.XBrushes.Black, rect_col_productdesc, PdfSharp.Drawing.XStringFormats.Center);
		gfx.DrawString(PRODUCTALIAS[i], subfont, PdfSharp.Drawing.XBrushes.Black, rect_col_productalias, PdfSharp.Drawing.XStringFormats.Center);
		gfx.DrawString(Quantity[i].ToString("F0"), subfont, PdfSharp.Drawing.XBrushes.Black, rect_col_quantity, PdfSharp.Drawing.XStringFormats.Center);
		gfx.DrawString(SerialNo[i], smallfont, PdfSharp.Drawing.XBrushes.Black, rect_col_serialno, PdfSharp.Drawing.XStringFormats.Center);
		
	}

	//打印人 打印时间
	
	//数量大于18，添加PDF页面 
	if(Index.Length>18)
	{
		//判断需要生成几页PDF
		if(Index.Length-18%20==0)
		{
			pagecount=(Index.Length-18)/20;
		}
		else
		{
			pagecount=(Index.Length-18)/20+1;
		}
		//获取数据
		List<int> Indexdata=Index.ToList();
		List<string> WipOrderNodata=WipOrderNo.ToList();
		List<string> ProductDescdata=ProductDesc.ToList();
		List<string> ProductNodata=ProductNo.ToList();
		List<string> PRODUCTALIASdata=PRODUCTALIAS.ToList();
		List<decimal> Quantitydata=Quantity.ToList();
		List<string> SerialNodata=SerialNo.ToList();
		for(int j=0;j<pagecount;j++)
		{
			//创建用于获取未填充至PDF的数据List
				List<int> IndexArr=new List<int>();
				List<string> WipOrderNoArr=new List<string>();
				List<string> ProductDescArr=new List<string>();
				List<string> ProductNoArr=new List<string>();
			    List<string> PRODUCTALIASArr=new List<string>();
				List<decimal> QuantityArr=new List<decimal>();
				List<string> SerialNoArr=new List<string>();
			//分页（每页20条数据，第一页18条） 判断剩下的数据是否超过20条
			if(Indexdata.Skip(18).Skip(20*j).ToArray().Length>=20)
			{
				 IndexArr=Indexdata.Skip(18).Skip(20*j).Take(20).ToList();
				 WipOrderNoArr=WipOrderNodata.Skip(18).Skip(20*j).Take(20).ToList();
				 ProductDescArr=ProductDescdata.Skip(18).Skip(20*j).Take(20).ToList();
				 ProductNoArr=ProductNodata.Skip(18).Skip(20*j).Take(20).ToList();
				 QuantityArr=Quantitydata.Skip(18).Skip(20*j).Take(20).ToList();
				 SerialNoArr=SerialNodata.Skip(18).Skip(20*j).Take(20).ToList();
				 PRODUCTALIASArr=PRODUCTALIASdata.Skip(18).Skip(20*j).Take(20).ToList();
			}
			else
			{
				 IndexArr=Indexdata.Skip(18).Skip(20*j).ToList();
				 WipOrderNoArr=WipOrderNodata.Skip(18).Skip(20*j).ToList();
				 ProductDescArr=ProductDescdata.Skip(18).Skip(20*j).ToList();
				 ProductNoArr=ProductNodata.Skip(18).Skip(20*j).ToList();
				 QuantityArr=Quantitydata.Skip(18).Skip(20*j).ToList();
				 SerialNoArr=SerialNodata.Skip(18).Skip(20*j).ToList();
				 PRODUCTALIASArr=PRODUCTALIASdata.Skip(18).Skip(20*j).ToList();
			}
			
		
	//添加页面
	PdfSharp.Pdf.PdfPage page2 = pdfDocument.AddPage();
	//获取绘制对象
	PdfSharp.Drawing.XGraphics gfx2 = PdfSharp.Drawing.XGraphics.FromPdfPage(page2);
	//文本布局对象
	
	for(int i=0;i<IndexArr.Count;i++)
	{	
		double Height_Y = row_height * i;
		//格子位置
		rect_col_index = new PdfSharp.Drawing.XRect(table_rect.X, 
		table_rect.Y + title_height + Height_Y, col_index, row_height);
		rect_col_wiporderno = new PdfSharp.Drawing.XRect(table_rect.X + col_index, 
		table_rect.Y + title_height + Height_Y, col_wiporderno, row_height);
		rect_col_productno = new PdfSharp.Drawing.XRect(table_rect.X + col_index + col_wiporderno, 
		table_rect.Y + title_height + Height_Y, col_productno, row_height);
		rect_col_productdesc = new PdfSharp.Drawing.XRect(table_rect.X + col_index + col_wiporderno + col_productno, 
		table_rect.Y + title_height + Height_Y, col_productdesc, row_height);
		rect_col_productalias = new PdfSharp.Drawing.XRect(table_rect.X + col_index + col_wiporderno + col_productno  + col_productdesc, 
		table_rect.Y + title_height + Height_Y, col_productalias, row_height);
		rect_col_quantity = new PdfSharp.Drawing.XRect(table_rect.X + col_index + col_wiporderno + col_productno + col_productdesc + col_productalias, 
		table_rect.Y + title_height + Height_Y, col_quantity, row_height);
		rect_col_serialno = new PdfSharp.Drawing.XRect(table_rect.X + col_index + col_wiporderno + col_productno + col_productdesc + col_productalias +  col_quantity, 
		table_rect.Y + title_height + Height_Y, col_serialno, row_height);
		//画格子边框
		gfx2.DrawRectangle(pen, rect_col_index);
		gfx2.DrawRectangle(pen, rect_col_wiporderno);
		gfx2.DrawRectangle(pen, rect_col_productno);
		gfx2.DrawRectangle(pen, rect_col_productdesc);
	    gfx2.DrawRectangle(pen, rect_col_productalias);
		gfx2.DrawRectangle(pen, rect_col_quantity);
		gfx2.DrawRectangle(pen, rect_col_serialno);
		//填充每一列的内容
		gfx2.DrawString(IndexArr[i].ToString("F0"), smallfont, PdfSharp.Drawing.XBrushes.Black, rect_col_index, PdfSharp.Drawing.XStringFormats.Center);
		gfx2.DrawString(WipOrderNoArr[i], smallfont, PdfSharp.Drawing.XBrushes.Black, rect_col_wiporderno, PdfSharp.Drawing.XStringFormats.Center);
		gfx2.DrawString(ProductNoArr[i], smallfont, PdfSharp.Drawing.XBrushes.Black, rect_col_productno, PdfSharp.Drawing.XStringFormats.Center);
		gfx2.DrawString(ProductDescArr[i], smallfont, PdfSharp.Drawing.XBrushes.Black, rect_col_productdesc, PdfSharp.Drawing.XStringFormats.Center);
		gfx2.DrawString(PRODUCTALIASArr[i], smallfont, PdfSharp.Drawing.XBrushes.Black, rect_col_productalias, PdfSharp.Drawing.XStringFormats.Center);
		gfx2.DrawString(QuantityArr[i].ToString("F0"), smallfont, PdfSharp.Drawing.XBrushes.Black, rect_col_quantity, PdfSharp.Drawing.XStringFormats.Center);
		gfx2.DrawString(SerialNoArr[i], smallfont, PdfSharp.Drawing.XBrushes.Black, rect_col_serialno, PdfSharp.Drawing.XStringFormats.Center);
	}	
			
			if(j.Equals(pagecount-1))
			{
				
				string systime = DateTime.Now.ToString();
				PdfSharp.Drawing.XRect rect_print = new PdfSharp.Drawing.XRect(rect.Width / 2 + 15, 
				table_rect.Y + title_height + row_height * IndexArr.Count + 15, rect.Width / 2, title_height);

				gfx2.DrawString("打印人："+PrintUser+"  打印日期："+systime, subfont, PdfSharp.Drawing.XBrushes.Black, rect_print, PdfSharp.Drawing.XStringFormats.TopLeft);
			}
		}
	}
	else
	{
			string systime = DateTime.Now.ToString();
				PdfSharp.Drawing.XRect rect_print = new PdfSharp.Drawing.XRect(rect.Width / 2 + 15, 
				table_rect.Y + title_height + row_height * fristCount + 15, rect.Width / 2, title_height);

				gfx.DrawString("打印人："+PrintUser+"  打印日期："+systime, subfont, PdfSharp.Drawing.XBrushes.Black, rect_print, PdfSharp.Drawing.XStringFormats.TopLeft);
	}
	
	//保存路径
	string savePath = FlexNet.SystemServices.FrameworkSettings.Current.FlexNetResourcesPath+"\\PDF2Print";
    //生成最终pdf文件
    pdfName = "ProductionEntry"+OrderNo;				
	var saveURL = savePath + "\\" + pdfName + ".pdf";
	var isExists = System.IO.File.Exists(saveURL);
	if(!isExists){
		//System.IO.File.Delete(saveURL);
		pdfDocument.Save(saveURL);
	}
    else{
		Random ra = new Random();
		pdfName = "ProductionEntry"+OrderNo+"_" + ra.Next(0,100);
		saveURL = savePath + "\\" + pdfName + ".pdf";
		pdfDocument.Save(saveURL);
	}
}
```

