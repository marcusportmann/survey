/*
 * Copyright 2016 Marcus Portmann
 * All rights reserved.
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package digital.survey.web.pages;

//~--- non-JDK imports --------------------------------------------------------

import guru.mmp.application.web.pages.WebPageSecurity;
import guru.mmp.application.web.template.TemplateSecurity;
import guru.mmp.application.web.template.pages.TemplateWebPage;

/**
 * The <code>DashboardPage</code> class implements the "Dashboard"
 * page for the web application.
 *
 * @author Marcus Portmann
 */
@WebPageSecurity(TemplateSecurity.FUNCTION_CODE_DASHBOARD)
public class DashboardPage extends TemplateWebPage
{
  private static final long serialVersionUID = 1000000;

  /**
   * Constructs a new <code>DashboardPage</code>.
   */
  public DashboardPage()
  {
    super("Dashboard");
  }
}
