import { useMutation, useQueryClient } from "@tanstack/react-query";
import { useState } from "react";
import { axiosInstance } from "../../lib/axios";
import toast from "react-hot-toast";
import { Loader } from "lucide-react";
import { useNavigate } from "react-router-dom"; 

const LoginForm = ({onLogin}) => {
	const [username, setUsername] = useState("");
	const [password, setPassword] = useState("");
	const queryClient = useQueryClient();
	const navigate = useNavigate();

	const { mutate: loginMutation, isLoading } = useMutation({
		mutationFn: () => axiosInstance.get(`/auth/login?email=${username}&password=${password}`),
		onSuccess: (response) => {
			const { userData, token } = response.data; // Extract userData and token from the first response
	
			// Make the second request using userData.id and token
			axiosInstance.get(`/users/getbyid/${userData.id}?jwt=${token}`)
				.then((userResponse) => {
					const fullUserData = userResponse.data; // Full user data from the second request
					onLogin(fullUserData, token); // Pass full user data and token to onLogin
					queryClient.setQueryData(["authUser"], fullUserData);
					queryClient.invalidateQueries({ queryKey: ["authUser"] }); // Optionally invalidate any related queries
					
				})
				.catch((error) => {
					toast.error(error.response?.data?.message || "Failed to fetch full user data");
				});
		},
		onError: (err) => {
			toast.error(err.response?.data?.message || "Login failed");
		},
	});

	const handleSubmit = (e) => {
		e.preventDefault();
		loginMutation({ username, password });
	};

	return (
		<form onSubmit={handleSubmit} className='space-y-4 w-full max-w-md'>
			<input
				type='text'
				placeholder='Username'
				value={username}
				onChange={(e) => setUsername(e.target.value)}
				className='input input-bordered w-full'
				required
			/>
			<input
				type='password'
				placeholder='Password'
				value={password}
				onChange={(e) => setPassword(e.target.value)}
				className='input input-bordered w-full'
				required
			/>

			<button type='submit' className='btn btn-primary w-full'>
				{isLoading ? <Loader className='size-5 animate-spin' /> : "Login"}
			</button>
		</form>
	);
};
export default LoginForm;
