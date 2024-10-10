import Layout from "./components/layout/Layout.jsx";
import HomePage from "./pages/HomePage.jsx";
import SignUpPage from "./pages/auth/SignUpPage.jsx";
import LoginPage from "./pages/auth/LoginPage.jsx";
import ProfilePage from "./pages/ProfilePage.jsx";
import {Route,Routes} from 'react-router-dom';

function App() {

  return (<Layout>
      <Routes>
        <Route path='/' element = {<HomePage/>}/>
        <Route path='/signup' element = {<SignUpPage/>}/>
        <Route path='/login' element = {<LoginPage/>}/>
        <Route path='/profile' element = {<ProfilePage/>}/>

      </Routes>
  </Layout>);
}

export default App
