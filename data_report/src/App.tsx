import { useState } from "react";
import "./App.css";
import * as XLSX from "xlsx";

interface TransactionData {
  no?: string;
  date?: string;
  time?: string;
  station?: string;
  pump?: string;
  product?: string;
  quantity?: number;
  unitPrice?: number;
  totalAmount?: number;
  paymentMethod?: string;
  customerCode?: string;
  customerName?: string;
  customerType?: string;
  paymentDate?: string;
  employee?: string;
  licensePlate?: string;
  invoiceStatus?: string;
}

function App() {
  const [data, setData] = useState<TransactionData[]>([]);
  const [startTime, setStartTime] = useState<string>("");
  const [endTime, setEndTime] = useState<string>("");
  const [filteredTotal, setFilteredTotal] = useState<number>(0);
  const [fileName, setFileName] = useState<string>("");
  const [filteredData, setFilteredData] = useState<TransactionData[]>([]);

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const reader = new FileReader();
    const file = e.target.files?.[0];
    if (file) {
      setFileName(file.name);
      reader.readAsArrayBuffer(file);
      reader.onload = (e) => {
        try {
          const arrayBuffer = e.target?.result as ArrayBuffer;
          const workbook = XLSX.read(arrayBuffer, { type: "array" });
          const sheetName = workbook.SheetNames[0];
          const sheet = workbook.Sheets[sheetName];
          let json = XLSX.utils.sheet_to_json(sheet, {
            header: 1,
            defval: "",
          });

          json = json.slice(7);

          const processedData: TransactionData[] = json
            .map((row: any) => {
              return {
                no: row[0]?.toString() || "",
                date: row[1]?.toString() || "",
                time: row[2]?.toString() || "",
                station: row[3]?.toString() || "",
                pump: row[4]?.toString() || "",
                product: row[5]?.toString() || "",
                quantity:
                  parseFloat(row[6]?.toString().replace(/,/g, "") || "0") || 0,
                unitPrice:
                  parseFloat(row[7]?.toString().replace(/,/g, "") || "0") || 0,
                totalAmount:
                  parseFloat(row[8]?.toString().replace(/,/g, "") || "0") || 0,
                paymentMethod: row[9]?.toString() || "",
                customerCode: row[10]?.toString() || "",
                customerName: row[11]?.toString() || "",
                customerType: row[12]?.toString() || "",
                paymentDate: row[13]?.toString() || "",
                employee: row[14]?.toString() || "",
                licensePlate: row[15]?.toString() || "",
                invoiceStatus: row[16]?.toString() || "",
              };
            })
            .filter(
              (item) =>
                item.time &&
                item.product &&
                item.time.includes(":") &&
                typeof item.no === "string" &&
                item.no !== "STT"
            );

          setData(processedData);
        } catch (error) {
          alert("Có lỗi khi đọc file Excel. Vui lòng kiểm tra định dạng file.");
        }
      };
    }
  };

  const parseTimeString = (timeStr: string): Date | null => {
    if (!timeStr) return null;

    const simpleHourMatch = timeStr.trim().match(/^(\d{1,2})$/);
    if (simpleHourMatch) {
      const hours = parseInt(simpleHourMatch[1]);
      if (hours >= 0 && hours <= 23) {
        const date = new Date();
        date.setHours(hours, 0, 0, 0);
        return date;
      }
    }

    const formats = [/(\d{1,2}):(\d{2}):(\d{2})/];

    for (const format of formats) {
      const match = timeStr.toString().match(format);
      if (match) {
        const hours = parseInt(match[1]);
        const minutes = parseInt(match[2]);
        const seconds = parseInt(match[3]);

        if (
          hours >= 0 &&
          hours <= 23 &&
          minutes >= 0 &&
          minutes <= 59 &&
          seconds >= 0 &&
          seconds <= 59
        ) {
          const date = new Date();
          date.setHours(hours, minutes, seconds, 0);
          return date;
        }
      }
    }

    return null;
  };

  const calculateTotal = () => {
    if (!startTime || !endTime) {
      alert("Vui lòng nhập đầy đủ thời gian bắt đầu và kết thúc");
      return;
    }

    const startDate = parseTimeString(startTime);
    const endDate = parseTimeString(endTime);

    if (!startDate || !endDate) {
      alert(
        "Định dạng thời gian không hợp lệ. Vui lòng sử dụng format 24h (VD: 9, 18)"
      );
      return;
    }

    const filtered = data.filter((item) => {
      const itemTime = parseTimeString(item.time || "");
      if (!itemTime) return false;

      return itemTime >= startDate && itemTime <= endDate;
    });

    const total = filtered.reduce((sum, item) => {
      const amount = item.totalAmount || item.quantity! * item.unitPrice! || 0;
      return sum + amount;
    }, 0);

    setFilteredData(filtered);
    setFilteredTotal(total);
  };

  return (
    <div className="min-h-screen bg-gray-50 p-8">
      <div className="max-w-6xl mx-auto">
        <h1 className="text-3xl font-bold text-gray-800 mb-8 text-center">
          Báo Cáo Giao Dịch Cửa Hàng Xăng Dầu
        </h1>

        <div className="bg-white rounded-lg shadow-md p-6 mb-6">
          <h2 className="text-xl font-semibold mb-4">Tải lên file báo cáo</h2>
          <div className="border-2 border-dashed border-gray-300 rounded-lg p-6 text-center">
            <input
              type="file"
              accept=".xlsx,.xls"
              onChange={handleFileChange}
              className="hidden"
              id="file-upload"
            />
            <label
              htmlFor="file-upload"
              className="cursor-pointer bg-blue-500 hover:bg-blue-600 text-white px-6 py-2 rounded-lg"
            >
              Chọn file Excel
            </label>
            {fileName && (
              <p className="mt-2 text-sm text-gray-600">Đã tải: {fileName}</p>
            )}
          </div>
        </div>

        {data.length > 0 && (
          <div className="bg-white rounded-lg shadow-md p-6 mb-6">
            <h2 className="text-xl font-semibold mb-4">Lọc theo thời gian</h2>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4 items-end">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Thời gian bắt đầu
                </label>
                <input
                  type="text"
                  value={startTime}
                  onChange={(e) => setStartTime(e.target.value)}
                  placeholder="Nhập định dạng 24h (VD: 9, 18)"
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Thời gian kết thúc
                </label>
                <input
                  type="text"
                  value={endTime}
                  onChange={(e) => setEndTime(e.target.value)}
                  placeholder="Nhập định dạng 24h (VD: 9, 18)"
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg"
                />
              </div>
              <div>
                <button
                  onClick={calculateTotal}
                  className="w-full bg-green-500 hover:bg-green-600 text-white px-6 py-2 rounded-lg transition duration-200"
                >
                  Tính tổng
                </button>
              </div>
            </div>
          </div>
        )}

        {filteredTotal > 0 && (
          <div className="bg-white rounded-lg shadow-md p-6 mb-6">
            <h2 className="text-xl font-semibold mb-4">Kết quả tính toán</h2>
            <div className="bg-green-50 border border-green-200 rounded-lg p-6">
              <div className="flex justify-between gap-4">
                <div>
                  <p className="text-lg">
                    <span className="font-medium">Số giao dịch:</span>
                    <span className="ml-2">
                      {filteredData.length} giao dịch
                    </span>
                  </p>
                  <p className="text-lg">
                    <span className="font-medium">Tổng lượng bán:</span>
                    <span className="ml-2">
                      {filteredData
                        .reduce((sum, item) => sum + (item.quantity || 0), 0)
                        .toFixed(2)}{" "}
                      lít
                    </span>
                  </p>
                </div>
                <div className="text-right">
                  <p className="text-sm text-gray-600">Tổng thành tiền</p>
                  <p className="text-3xl font-bold text-green-600">
                    {filteredTotal.toLocaleString("vi-VN")} VNĐ
                  </p>
                </div>
              </div>
            </div>
          </div>
        )}

        {filteredData.length > 0 && (
          <div className="bg-white rounded-lg shadow-md p-6 mb-6">
            <h2 className="text-xl font-semibold mb-4">
              Chi tiết giao dịch trong khoảng thời gian
            </h2>
            <div className="overflow-x-auto">
              <table className="min-w-full border-collapse border border-gray-300">
                <thead>
                  <tr className="bg-gray-50">
                    <th className="border border-gray-300 px-2 py-2 text-left text-sm">
                      STT
                    </th>
                    <th className="border border-gray-300 px-2 py-2 text-left text-sm">
                      Ngày
                    </th>
                    <th className="border border-gray-300 px-2 py-2 text-left text-sm">
                      Thời gian
                    </th>
                    <th className="border border-gray-300 px-2 py-2 text-left text-sm">
                      Trụ bơm
                    </th>
                    <th className="border border-gray-300 px-2 py-2 text-left text-sm">
                      Mặt hàng
                    </th>
                    <th className="border border-gray-300 px-2 py-2 text-right text-sm">
                      Số lượng
                    </th>
                    <th className="border border-gray-300 px-2 py-2 text-right text-sm">
                      Đơn giá
                    </th>
                    <th className="border border-gray-300 px-2 py-2 text-right text-sm">
                      Thành tiền (VNĐ)
                    </th>
                    <th className="border border-gray-300 px-2 py-2 text-left text-sm">
                      Thanh toán
                    </th>
                  </tr>
                </thead>
                <tbody>
                  {filteredData.map((item, index) => (
                    <tr key={index} className="hover:bg-gray-50">
                      <td className="border border-gray-300 px-2 py-2 text-sm">
                        {item.no}
                      </td>
                      <td className="border border-gray-300 px-2 py-2 text-sm">
                        {item.date}
                      </td>
                      <td className="border border-gray-300 px-2 py-2 text-sm">
                        {item.time}
                      </td>
                      <td className="border border-gray-300 px-2 py-2 text-sm">
                        {item.pump}
                      </td>
                      <td className="border border-gray-300 px-2 py-2 text-sm">
                        {item.product}
                      </td>
                      <td className="border border-gray-300 px-2 py-2 text-right text-sm">
                        {item.quantity?.toFixed(2)}
                      </td>
                      <td className="border border-gray-300 px-2 py-2 text-right text-sm">
                        {item.unitPrice?.toLocaleString("vi-VN")}
                      </td>
                      <td className="border border-gray-300 px-2 py-2 text-right text-sm font-medium">
                        {(
                          item.totalAmount || item.quantity! * item.unitPrice!
                        ).toLocaleString("vi-VN")}
                      </td>
                      <td className="border border-gray-300 px-2 py-2 text-sm">
                        {item.paymentMethod}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

export default App;
