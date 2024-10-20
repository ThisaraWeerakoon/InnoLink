import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { useEffect, useState } from "react";
import { axiosInstance } from "../lib/axios";
import toast from "react-hot-toast";
import { Link, useParams } from "react-router-dom";
import { DollarSign, Loader, MessageCircle, Send, Share2, ThumbsUp, Trash2 } from "lucide-react";
import { formatDistanceToNow } from "date-fns";

import PostAction from "./PostAction";





const Post = ({ post }) => {
	const { postId } = useParams();

	const { data: authUser } = useQuery({ queryKey: ["authUser"] });
	const [showComments, setShowComments] = useState(false);
	const [newComment, setNewComment] = useState("");
	const [comments, setComments] = useState(post.comments || []);
	const isOwner = authUser.id === post.userId;
	//const isLiked = post.likes.includes(authUser.id);

	const queryClient = useQueryClient();


	const token= localStorage.getItem('jwt');


	const { data: isLiked } = useQuery({
		queryKey: ["isLiked", post.id, authUser?.id],
		queryFn: async () => {
		  const res = await axiosInstance.get(`/likes/isliked?userId=${authUser?.id}&postId=${post.id}&jwt=${token}`);
		  return res.data === 1; // Convert 1 to true and 0 to false
		},
	    enabled: !!token,
	  });
	  


	const { data: NewComments } = useQuery({
		queryKey: ["comments"],
		queryFn: async () => {
			const res = await axiosInstance.get(`/comments/getallbypost?postId=${post.id}&jwt=${token}`);
			return res.data;
		},
		enabled: !!token,
	});

	useEffect(() => {
        console.log("Fetched comments:", NewComments); // Log the fetched comments
        setComments(NewComments); // Set the comments state
    },[NewComments])
    
	const { mutate: deletePost, isPending: isDeletingPost } = useMutation({
		mutationFn: async () => {
			await axiosInstance.delete(`/posts/delete?postId=${post.id}&jwt=${token}`);
		},
		onSuccess: () => {
			queryClient.invalidateQueries({ queryKey: ["posts"] });
			toast.success("Post deleted successfully");
		},
		onError: (error) => {
			toast.error(error.message);
		},
	});

	const { mutate: createComment, isPending: isAddingComment } = useMutation({
		mutationFn: async (newComment) => {
			await axiosInstance.post(`/comments/add?userId=${authUser.id}&postId=${post.id}&jwt=${token}&content=${newComment}`);
		},
		onSuccess: () => {
			queryClient.invalidateQueries({ queryKey: ["posts"] });
			toast.success("Comment added successfully");
		},
		onError: (err) => {
			toast.error(err.response.data.message || "Failed to add comment");
		},
	});

	const { mutate: likePost, isPending: isLikingPost } = useMutation({
		mutationFn: async () => {
			await axiosInstance.post(`/likes/add?userId=${authUser.id}&postId=${post.id}&jwt=${token}`);
		},
		onSuccess: () => {
			queryClient.invalidateQueries({ queryKey: ["posts"] });
			queryClient.invalidateQueries({ queryKey: ["isLiked", post.id, authUser?.id] });

			queryClient.invalidateQueries({ queryKey: ["post", postId] });
			toast.success("Like added successfully");
		},
	});

	const handleDeletePost = () => {
		if (!window.confirm("Are you sure you want to delete this post?")) return;
		deletePost();
	};

	const handleLikePost = async () => {
		if (isLikingPost) return;
		likePost();
	};

	const handleAddComment = async (e) => {
		e.preventDefault();
		if (newComment.trim()) {
			createComment(newComment);
			setNewComment("");
			setComments([
				...comments,
				{
					id: `${Date.now()}-${Math.random().toString(36).substr(2, 9)}`, // Or any method to generate the `id`
					content: newComment,
					media: null, // As `media` is `null` in the given structure
					created_at: [
					  Math.floor(Date.now() / 1000), // Convert current time to seconds
					  0  // Nanoseconds are 0 by default (adjust if needed)
					],
					userId: authUser.id, // Assuming `authUser` is available
					postId: post.id // Use the post ID you're working with
				  }
			]);
		}
	};
	
	return (
		<div className='bg-secondary rounded-lg shadow mb-4'>
			<div className='p-4'>
				<div className='flex items-center justify-between mb-4'>
					<div className='flex items-center'>
						<img
							src={post.authUser || "/avatar.png"}
							alt={post.authUser || "Profile Picture"}
							className='size-10 rounded-full mr-3'
						/>
		

						<div>
							<Link to={`/profile/${post?.author?.username}`}>
								{/*<h3 className='font-semibold'>{post.author.name}</h3>*/}
							</Link>
							<p className='text-xs text-info'>{post.caption}</p>
							{/*<p className='text-xs text-info'>
								{formatDistanceToNow(new Date(post.createdAt), { addSuffix: true })}
							</p>*/}
						</div>
					</div>
					{isOwner && (
						<button onClick={handleDeletePost} className='text-red-500 hover:text-red-700'>
							{isDeletingPost ? <Loader size={18} className='animate-spin' /> : <Trash2 size={18} />}
						</button>
					)}
				</div>
				<p className='mb-4'>{post.content}</p>
				{/*{post.image && <img src={post.image} alt='Post content' className='rounded-lg w-full mb-4' />}*/}

				<div className='flex justify-between text-info'>
					<PostAction
						icon={<ThumbsUp size={18} className={ isLiked ? "text-blue-500  fill-blue-300" : ""} />}
						text={`Like`}
						onClick={handleLikePost}
					/>

					<PostAction
						icon={<MessageCircle size={18} />}
						text={`Comment (${comments?.length})`}
						onClick={() => setShowComments(!showComments)}
					/>
					<PostAction icon={<DollarSign size={18} />} text='Invest' />
				</div>
			</div>

			{showComments && (
				<div className='px-4 pb-4'>
					<div className='mb-4 max-h-60 overflow-y-auto'>
						{comments?.map((comment) => (
							<div key={comment.id} className='mb-2 bg-base-100 p-2 rounded flex items-start'>
								<img
									src={comment.userId || "/avatar.png"}
									alt={comment.userId}
									className='w-8 h-8 rounded-full mr-2 flex-shrink-0'
								/>
								<div className='flex-grow'>
									<div className='flex items-center mb-1'>
										<span className='font-semibold mr-2'>{comment.userId}</span>
										<span className='text-xs text-info'>
										{formatDistanceToNow(new Date(comment.created_at[0] * 1000))}
										</span>
									</div>
									<p>{comment.content}</p>
								</div>
							</div>
						))}
					</div>

					<form onSubmit={handleAddComment} className='flex items-center'>
						<input
							type='text'
							value={newComment}
							onChange={(e) => setNewComment(e.target.value)}
							placeholder='Add a comment...'
							className='flex-grow p-2 rounded-l-full bg-base-100 focus:outline-none focus:ring-2 focus:ring-primary'
						/>

						<button
							type='submit'
							className='bg-primary text-white p-2 rounded-r-full hover:bg-primary-dark transition duration-300'
							disabled={isAddingComment}
						>
							{isAddingComment ? <Loader size={18} className='animate-spin' /> : <Send size={18} />}
						</button>
					</form>
				</div>
			)}
		</div>
	);
};
export default Post;
