import { render } from "@testing-library/react";
import { axe } from "jest-axe";
import Home from "../app/page";

test("home is accessible", async () => {
  const { container } = render(<Home />);
  expect(await axe(container)).toHaveNoViolations();
});
