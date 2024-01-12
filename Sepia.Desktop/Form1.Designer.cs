namespace Sepia.Desktop
{
    partial class Form1
    {
        /// <summary>
        ///  Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        ///  Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        ///  Required method for Designer support - do not modify
        ///  the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            button1 = new Button();
            button2 = new Button();
            trackBarSepiaIntensity = new TrackBar();
            trackBarThreads = new TrackBar();
            label1 = new Label();
            label2 = new Label();
            pictureBoxOriginal = new PictureBox();
            pictureBoxSepia = new PictureBox();
            comboBoxLib = new ComboBox();
            label3 = new Label();
            benchmarkLabel = new Label();
            ((System.ComponentModel.ISupportInitialize)trackBarSepiaIntensity).BeginInit();
            ((System.ComponentModel.ISupportInitialize)trackBarThreads).BeginInit();
            ((System.ComponentModel.ISupportInitialize)pictureBoxOriginal).BeginInit();
            ((System.ComponentModel.ISupportInitialize)pictureBoxSepia).BeginInit();
            SuspendLayout();
            // 
            // button1
            // 
            button1.Location = new Point(12, 12);
            button1.Name = "button1";
            button1.Size = new Size(207, 29);
            button1.TabIndex = 0;
            button1.Text = "Select File";
            button1.UseVisualStyleBackColor = true;
            button1.Click += button1_Click;
            // 
            // button2
            // 
            button2.Enabled = false;
            button2.Location = new Point(12, 63);
            button2.Name = "button2";
            button2.Size = new Size(207, 29);
            button2.TabIndex = 1;
            button2.Text = "Process";
            button2.UseVisualStyleBackColor = true;
            button2.Click += button2_Click;
            // 
            // trackBarSepiaIntensity
            // 
            trackBarSepiaIntensity.Location = new Point(12, 134);
            trackBarSepiaIntensity.Maximum = 100;
            trackBarSepiaIntensity.Name = "trackBarSepiaIntensity";
            trackBarSepiaIntensity.Size = new Size(207, 56);
            trackBarSepiaIntensity.TabIndex = 2;
            trackBarSepiaIntensity.TickStyle = TickStyle.None;
            // 
            // trackBarThreads
            // 
            trackBarThreads.LargeChange = 4;
            trackBarThreads.Location = new Point(12, 212);
            trackBarThreads.Maximum = 64;
            trackBarThreads.Minimum = 1;
            trackBarThreads.Name = "trackBarThreads";
            trackBarThreads.Size = new Size(207, 56);
            trackBarThreads.TabIndex = 3;
            trackBarThreads.TickFrequency = 4;
            trackBarThreads.Value = 1;
            // 
            // label1
            // 
            label1.AutoSize = true;
            label1.Location = new Point(12, 189);
            label1.Name = "label1";
            label1.Size = new Size(61, 20);
            label1.TabIndex = 4;
            label1.Text = "Threads";
            // 
            // label2
            // 
            label2.AutoSize = true;
            label2.Location = new Point(12, 111);
            label2.Name = "label2";
            label2.Size = new Size(105, 20);
            label2.TabIndex = 5;
            label2.Text = "Sepia intensity";
            // 
            // pictureBoxOriginal
            // 
            pictureBoxOriginal.BackgroundImageLayout = ImageLayout.None;
            pictureBoxOriginal.Location = new Point(238, 12);
            pictureBoxOriginal.Name = "pictureBoxOriginal";
            pictureBoxOriginal.Size = new Size(659, 372);
            pictureBoxOriginal.SizeMode = PictureBoxSizeMode.Zoom;
            pictureBoxOriginal.TabIndex = 6;
            pictureBoxOriginal.TabStop = false;
            // 
            // pictureBoxSepia
            // 
            pictureBoxSepia.BackgroundImageLayout = ImageLayout.None;
            pictureBoxSepia.Location = new Point(238, 426);
            pictureBoxSepia.Name = "pictureBoxSepia";
            pictureBoxSepia.Size = new Size(659, 372);
            pictureBoxSepia.SizeMode = PictureBoxSizeMode.Zoom;
            pictureBoxSepia.TabIndex = 7;
            pictureBoxSepia.TabStop = false;
            // 
            // comboBoxLib
            // 
            comboBoxLib.DropDownStyle = ComboBoxStyle.DropDownList;
            comboBoxLib.FormattingEnabled = true;
            comboBoxLib.Location = new Point(12, 274);
            comboBoxLib.Name = "comboBoxLib";
            comboBoxLib.Size = new Size(207, 28);
            comboBoxLib.TabIndex = 8;
            // 
            // label3
            // 
            label3.AutoSize = true;
            label3.Location = new Point(12, 338);
            label3.Name = "label3";
            label3.Size = new Size(146, 20);
            label3.TabIndex = 9;
            label3.Text = "Operation took (ms):";
            // 
            // benchmarkLabel
            // 
            benchmarkLabel.AutoSize = true;
            benchmarkLabel.Font = new Font("Segoe UI", 9F, FontStyle.Bold, GraphicsUnit.Point);
            benchmarkLabel.Location = new Point(12, 364);
            benchmarkLabel.Name = "benchmarkLabel";
            benchmarkLabel.Size = new Size(0, 20);
            benchmarkLabel.TabIndex = 10;
            // 
            // Form1
            // 
            AutoScaleDimensions = new SizeF(8F, 20F);
            AutoScaleMode = AutoScaleMode.Font;
            ClientSize = new Size(909, 810);
            Controls.Add(benchmarkLabel);
            Controls.Add(label3);
            Controls.Add(comboBoxLib);
            Controls.Add(pictureBoxSepia);
            Controls.Add(pictureBoxOriginal);
            Controls.Add(label2);
            Controls.Add(label1);
            Controls.Add(trackBarThreads);
            Controls.Add(trackBarSepiaIntensity);
            Controls.Add(button2);
            Controls.Add(button1);
            FormBorderStyle = FormBorderStyle.FixedDialog;
            Name = "Form1";
            Text = "Project JA - Sepia";
            ((System.ComponentModel.ISupportInitialize)trackBarSepiaIntensity).EndInit();
            ((System.ComponentModel.ISupportInitialize)trackBarThreads).EndInit();
            ((System.ComponentModel.ISupportInitialize)pictureBoxOriginal).EndInit();
            ((System.ComponentModel.ISupportInitialize)pictureBoxSepia).EndInit();
            ResumeLayout(false);
            PerformLayout();
        }

        #endregion

        private Button button1;
        private Button button2;
        private TrackBar trackBarSepiaIntensity;
        private TrackBar trackBarThreads;
        private Label label1;
        private Label label2;
        private PictureBox pictureBoxOriginal;
        private PictureBox pictureBoxSepia;
        private ComboBox comboBoxLib;
        private Label label3;
        private Label benchmarkLabel;
    }
}