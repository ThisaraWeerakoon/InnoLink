import { useMutation } from "@tanstack/react-query";
import { useState } from "react";
import { axiosInstance } from "../../lib/axios";
import toast from "react-hot-toast";
import { Loader } from "lucide-react";
import { useNavigate } from "react-router-dom";

const SignUpForm = () => {
  const [email, setEmail] = useState("");
  const [firstName, setFirstName] = useState("");
  const [lastName, setLastName] = useState("");
  const [dob, setDob] = useState({ year: "", month: "", day: "" });
  const [password, setPassword] = useState("");
  const navigate = useNavigate();

  const { mutate: signUpMutation, isLoading } = useMutation({
    mutationFn: (userData) => axiosInstance.post("/auth/register", userData),
    onSuccess: () => {
      toast.success("Account created successfully!");
	    navigate("/login");
	    },
    onError: (err) => {
      toast.error(err.response?.data?.message || "Something went wrong");
    },
  });

  const handleSubmit = (e) => {
    e.preventDefault();
    const requestData = {
      email,
      first_name: firstName,
      last_name: lastName,
      dob: {
        year: parseInt(dob.year, 10),
        month: parseInt(dob.month, 10),
        day: parseInt(dob.day, 10),
      },
      password,
    };
    signUpMutation(requestData);
  };
  

  return (
    <form onSubmit={handleSubmit} className="space-y-4 w-full max-w-md">
      <input
        type="email"
        placeholder="Email"
        value={email}
        onChange={(e) => setEmail(e.target.value)}
        className="input input-bordered w-full"
        required
      />
      <input
        type="text"
        placeholder="First Name"
        value={firstName}
        onChange={(e) => setFirstName(e.target.value)}
        className="input input-bordered w-full"
        required
      />
      <input
        type="text"
        placeholder="Last Name"
        value={lastName}
        onChange={(e) => setLastName(e.target.value)}
        className="input input-bordered w-full"
        required
      />

      <div className="flex space-x-2">
        <input
          type="number"
          placeholder="Year"
          value={dob.year}
          onChange={(e) => setDob({ ...dob, year: e.target.value })}
          className="input input-bordered w-1/3"
          required
        />
        <input
          type="number"
          placeholder="Month"
          value={dob.month}
          onChange={(e) => setDob({ ...dob, month: e.target.value })}
          className="input input-bordered w-1/3"
          required
        />
        <input
          type="number"
          placeholder="Day"
          value={dob.day}
          onChange={(e) => setDob({ ...dob, day: e.target.value })}
          className="input input-bordered w-1/3"
          required
        />
      </div>

      <input
        type="password"
        placeholder="Password"
        value={password}
        onChange={(e) => setPassword(e.target.value)}
        className="input input-bordered w-full"
        required
      />

      <button type="submit" className="btn btn-primary w-full">
        {isLoading ? <Loader className="size-5 animate-spin" /> : "Sign Up"}
      </button>
    </form>
  );
};

export default SignUpForm;
