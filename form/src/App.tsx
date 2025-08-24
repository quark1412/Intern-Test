import { useForm, Controller } from "react-hook-form";
import { yupResolver } from "@hookform/resolvers/yup";
import * as yup from "yup";
import DatePicker from "react-datepicker";
import toast, { Toaster } from "react-hot-toast";
import "react-datepicker/dist/react-datepicker.css";
import "./App.css";

const schema = yup.object({
  datetime: yup.date().required("Thời gian là bắt buộc"),
  quantity: yup
    .number()
    .typeError("Số lượng phải là số")
    .positive("Số lượng phải lớn hơn 0")
    .required("Số lượng là bắt buộc"),
  column: yup.string().required("Trụ là bắt buộc"),
  revenue: yup
    .number()
    .typeError("Doanh thu phải là số")
    .min(0, "Doanh thu không được âm")
    .required("Doanh thu là bắt buộc"),
  unitPrice: yup
    .number()
    .typeError("Đơn giá phải là số")
    .positive("Đơn giá phải lớn hơn 0")
    .required("Đơn giá là bắt buộc"),
});

type FormData = yup.InferType<typeof schema>;

function App() {
  const {
    control,
    handleSubmit,
    formState: { errors },
  } = useForm<FormData>({
    resolver: yupResolver(schema),
    defaultValues: {
      datetime: new Date(),
      quantity: 0,
      column: "",
      revenue: 0,
      unitPrice: 0,
    },
  });

  const onSubmit = (data: FormData) => {
    toast.success("Cập nhật giao dịch thành công!");
  };

  const onError = () => {
    toast.error("Vui lòng kiểm tra lại thông tin!");
  };

  return (
    <div className="min-h-screen bg-gray-50 p-8">
      <div className="max-w-2xl mx-auto">
        <div className="flex justify-between items-center mb-8 p-4 bg-white rounded-lg shadow-md">
          <h1 className="text-3xl font-bold text-gray-800">Nhập giao dịch</h1>

          <button
            type="submit"
            form="transaction-form"
            className="bg-blue-500 text-white px-6 py-2 rounded-md cursor-pointer hover:bg-blue-600 font-medium"
          >
            Cập nhật
          </button>
        </div>

        <div className="bg-white rounded-lg shadow-md p-8">
          <form
            id="transaction-form"
            onSubmit={handleSubmit(onSubmit, onError)}
            className="space-y-6"
          >
            <div>
              <label className="block text-gray-700 text-sm font-medium mb-2">
                Thời gian
              </label>
              <Controller
                name="datetime"
                control={control}
                render={({ field }) => (
                  <DatePicker
                    selected={field.value}
                    onChange={field.onChange}
                    showTimeSelect
                    timeFormat="HH:mm:ss"
                    timeIntervals={1}
                    dateFormat="dd/MM/yyyy HH:mm:ss"
                    className={`w-full px-4 py-3 border rounded-lg ${
                      errors.datetime ? "border-red-500" : "border-gray-300"
                    }`}
                    placeholderText="Chọn ngày và giờ"
                  />
                )}
              />
              {errors.datetime && (
                <p className="text-red-500 text-sm mt-1">
                  {errors.datetime.message}
                </p>
              )}
            </div>

            <div>
              <label className="block text-gray-700 text-sm font-medium mb-2">
                Số lượng
              </label>
              <Controller
                name="quantity"
                control={control}
                render={({ field }) => (
                  <input
                    type="text"
                    {...field}
                    className={`w-full px-4 py-3 border rounded-lg ${
                      errors.quantity ? "border-red-500" : "border-gray-300"
                    }`}
                    placeholder="0"
                  />
                )}
              />
              {errors.quantity && (
                <p className="text-red-500 text-sm mt-1">
                  {errors.quantity.message}
                </p>
              )}
            </div>

            <div>
              <label className="block text-gray-700 text-sm font-medium mb-2">
                Trụ *
              </label>
              <Controller
                name="column"
                control={control}
                render={({ field }) => (
                  <select
                    {...field}
                    className={`w-full px-4 py-3 border rounded-lg bg-white ${
                      errors.column ? "border-red-500" : "border-gray-300"
                    }`}
                  >
                    <option value="">Chọn trụ</option>
                    <option value="T01">Trụ 01</option>
                    <option value="T02">Trụ 02</option>
                    <option value="T03">Trụ 03</option>
                    <option value="T04">Trụ 04</option>
                    <option value="T05">Trụ 05</option>
                    <option value="T06">Trụ 06</option>
                  </select>
                )}
              />
              {errors.column && (
                <p className="text-red-500 text-sm mt-1">
                  {errors.column.message}
                </p>
              )}
            </div>

            <div>
              <label className="block text-gray-700 text-sm font-medium mb-2">
                Doanh thu
              </label>
              <Controller
                name="revenue"
                control={control}
                render={({ field }) => (
                  <input
                    type="text"
                    {...field}
                    className={`w-full px-4 py-3 border rounded-lg ${
                      errors.revenue ? "border-red-500" : "border-gray-300"
                    }`}
                    placeholder="0"
                  />
                )}
              />
              {errors.revenue && (
                <p className="text-red-500 text-sm mt-1">
                  {errors.revenue.message}
                </p>
              )}
            </div>

            <div>
              <label className="block text-gray-700 text-sm font-medium mb-2">
                Đơn giá
              </label>
              <Controller
                name="unitPrice"
                control={control}
                render={({ field }) => (
                  <input
                    type="text"
                    {...field}
                    className={`w-full px-4 py-3 border rounded-lg ${
                      errors.unitPrice ? "border-red-500" : "border-gray-300"
                    }`}
                    placeholder="0"
                  />
                )}
              />
              {errors.unitPrice && (
                <p className="text-red-500 text-sm mt-1">
                  {errors.unitPrice.message}
                </p>
              )}
            </div>
          </form>
        </div>
        <Toaster position="top-right" />
      </div>
    </div>
  );
}

export default App;
