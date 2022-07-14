import { render, screen, fireEvent } from "@testing-library/react";
import RegisterAccountsModal from "./RegisterAccountsModal";
import { Provider } from "react-redux";
import store from "../../redux/store";
import * as actions from "../../redux/actions/accounts";

const ReduxProvider = ({ children, reduxStore }) => <Provider store={reduxStore}>{children}</Provider>;

test("renders RegisterAccountsModal, cannot submit empty dialog", async () => {

    render(
        <ReduxProvider reduxStore={store}>
            <RegisterAccountsModal />
        </ReduxProvider>
    );
    const registerButtonElement = screen.getByRole("button", { name: "Register account(s)" })

    expect(screen.getByText(/register aws accounts/i)).toBeInTheDocument();

    expect(registerButtonElement).toBeEnabled()
    fireEvent.click(registerButtonElement)
    expect(registerButtonElement).toBeDisabled()
});

test("renders RegisterAccountsModal, enters valid and invalid texts, submits", async () => {

    const testObject = {
        roleName: 'OrganizationAccountAccessRole',
        accountIds: [
            "123456789012",
            "111222333444",
            "123456123456"
        ]
    }
    render(
        <ReduxProvider reduxStore={store}>
            <RegisterAccountsModal isAdminView/>
        </ReduxProvider>
    );
    expect(screen.getByText(/register aws accounts/i)).toBeInTheDocument();
    const accountsInputElement = screen.getByLabelText(/list of aws account ids to be registered/i);
    const roleInputElement = screen.getByLabelText(/admin role for backend account management tasks in children accounts./i);
    const registerButtonElement = screen.getByRole("button", { name: "Register account(s)" })

    // check if submit button is initially enabled
    expect(registerButtonElement).toBeEnabled()

    // try invalid and valid account list
    fireEvent.change(accountsInputElement, {target: {value: "123456789012,1a2b3c4d5e6f"}})
    expect(registerButtonElement).toBeDisabled()
    fireEvent.change(accountsInputElement, {target: {value: testObject.accountIds.join(",")}})
    expect(registerButtonElement).toBeEnabled()

    // try invalid and valid role name
    fireEvent.change(roleInputElement, {target: {value: 'invalid?role#name'}})
    expect(registerButtonElement).toBeDisabled()
    fireEvent.change(roleInputElement, {target: {value: testObject.roleName}})
    expect(registerButtonElement).toBeEnabled()

    // submit and test redux action call payload
    const registerUserAction = jest.spyOn(actions, "registerAccounts").mockImplementation((accounts) => () => accounts)
    fireEvent.click(registerButtonElement)
    expect(registerUserAction.mock.lastCall[0]).toMatchObject(testObject)
});
